//
//  AppData+UpdateUser.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine
import CoreData

extension AppData {
    
    //MARK:-获取用户信息方法
    
    
    /// 更新用户信息的入口
    func getUserInfo() {
        
        //如果没有设置用户ID，且可以读取userDefualt里的IDString（说明已经logined），则设置loginUser的userIDString为登陆用户的userIDString
        if self.loginUserID == "0000" && userDefault.object(forKey: "userIDString") != nil {
            self.loginUserID = userDefault.object(forKey: "userIDString") as! String
        }
        
        
//        //读取用户设置信息,目前还没有做到区分用户
//        setting.load()
        
        getUser(userIDString: loginUserID)
        
        
    }
    
    /// 获取用户信息，这部分是复用函数，既可以更新loginUser，也可以用来更新任意用户信息
    /// 如果传入到userIDString是新用户，则会在fetchMee .users里创建一个数据并更新
    /// 更新步骤是首先更新Bio信息，并整体打包赋值给相应的users数据位置
    /// TODO：增加screenName的参数
    /// - Parameter userIDString: 用户ID
    func getUser(userIDString: String) {
      
        let userTag = UserTag.id(userIDString)
        var user = User()
        
        ///第一步：
        /// 更新Bio信息，这部分信息需要从Twitter获取，通过一个成功回调函数来完成赋值
        /// 回调函数后段会完成继续对其他信息更新的步骤
        /// - Parameter json: 请求成功获取的JSON信息
        func getUserBio(json: JSON) {
            
            ///userBio信息更新开始
            user.id = json["id_str"].string!
            user.name = json["name"].string!
            user.screenName = "@" + json["screen_name"].string!
            user.description = json["description"].string!
            
            let ct = json["created_at"].string!.split(separator: " ")
            user.createdAt = " Joined " + String(ct[1]) + " " + String(ct[2]) + " " + String(ct[5]) //加入日期
            
            var avatarUrl = json["profile_image_url_https"].string
            avatarUrl = avatarUrl?.replacingOccurrences(of: "_normal", with: "")
            imageDownloaderWithClosure(from: avatarUrl, sh: {im in
                DispatchQueue.main.async {
                    self.users[userIDString]?.avatar = im
                }
                
            })
            
            user.bannerUrlString = json["profile_banner_url"].string
            print(#line," user bannerString",  user.bannerUrlString)
            imageDownloaderWithClosure(from: user.bannerUrlString, sh: {im in
                DispatchQueue.main.async {
                self.users[userIDString]?.banner = im
                }
                print(#line, "下载banner成功")
                })
                
            
            
            var loc = json["location"].string ?? "Unknow"
            if loc != "" {
                loc = " " + loc
            }
            user.loc = loc
            
            var url = json["url"].string ?? ""
            if url != "" {
                url = " " + url + "\n"
            }
            user.url = url
            
            user.following = json["friends_count"].integer!
            user.followed = json["followers_count"].integer!
            user.isFollowing = json["following"].bool
            
            user.notifications = json["notifications"].bool
            
            user.tweetsCount = json["statuses_count"].integer!
            
            
            ///从CoreData读取信息计算24小时内新增fo数和推文数量
            let results = updateCount(user: user)
            user.lastDayAddedFollower = results[0][0]
            user.lastDayAddedTweets = results[1][0]
            
            ///保存用户信息到CoreData，如果是登陆用户，则传入true
            saveUserInfoToCoreData(user: user)
            
            ///信息更新完成，将user数据替换到相应位置
            self.users[userIDString] = user
            
            ///第二步：
            ///开始更新List相应信息。
            ///这部分将直接更新users里面的user数据，
            ///所以需要在上面更新打包完成后才开始
            ///直接传入上方所获得的user.id
            getAndUpdateList(userIDString: user.id)
           
        }
        
        ///获取用户基本信息，并生成Bio
        swifter.showUser(userTag, includeEntities: nil, success: getUserBio(json:), failure: nil)
    }
    
    func getAndUpdateList(userIDString: String) {
        
        /// 获取用户List信息并更新
        /// - Parameter json: 返回的包含list信息的结果
        func updateList(json: JSON) {
            
            let lists: [JSON] = json.array!
            
            var newLists: [String : ListTag] = [:]
            for list in lists {
                let name: String = list["name"].string!
                let idString: String = list["id_str"].string!
                let listTag = ListTag.id(idString)
                newLists[name] = listTag
            }
            
            if newLists.isEmpty {
                let name: String = "No List"
                let idString: String = "0000"
                let listTag = ListTag.id(idString)
                newLists[name] = listTag
            }
            
            self.users[userIDString]?.lists = newLists
        }
        
        let userTag = UserTag.id(userIDString)
        
        swifter.getSubscribedLists(for: userTag,
                                   success:updateList)
    }
    
   
    
    
    func follow(userIDString: String) {
        print(#line, #function)
        let userTag = UserTag.id(userIDString)
        swifter.followUser(userTag)
        users[userIDString]?.isFollowing = true
    }
    
    func unfollow(userIDString: String) {
        let userTag = UserTag.id(userIDString)
        swifter.unfollowUser(userTag)
        users[userIDString]?.isFollowing = false
    }
    
    
    
    //MARK:-通用的image下载程序
    
    /**通用的image下载程序
     - Parameter urlString: 传入的下载地址
     - Parameter sh: 传入的闭包用来执行操作，往往用来赋值给数据
     
     */
    func imageDownloaderWithClosure(from urlString: String?, sh: @escaping (UIImage) -> Void ){
        ///利用这个闭包传入需要的操作，例如赋值
        ///为了通用，取消了传入闭包在主线程运行的设置，所以需要在各自闭包里面自行设置UI相关命令在主线程执行
        let sh: (UIImage) -> Void = sh
        
        guard urlString != nil  else {return}
        guard let url = URL(string: urlString!) else { return}
        let fileName = url.lastPathComponent ///获取下载文件名用于本地存储
        
        let cachelUrl = cfh.getPath()
        let filePath = cachelUrl.appendingPathComponent(fileName, isDirectory: false)
        
        ///先尝试获取本地缓存文件
        if let d = try? Data(contentsOf: filePath) {
            if let im = UIImage(data: d) {
//                DispatchQueue.main.async {
                    sh(im)
                    print(#line, "From local")
//                }
            }
        } else { //
            let task = self.session.downloadTask(with: url) {
                fileURL, resp, err in
                if let url = fileURL, let d = try? Data(contentsOf: url) {
                    if let im = UIImage(data: d) {
                        try? d.write(to: filePath)
//                        DispatchQueue.main.async {
                            sh(im)
                            print(#line, "From remote")
//                        }
                        
                    }
                }
            }
            task.resume()
        }
    }
    
    //MARK:-CoreData part
    func saveUserInfoToCoreData(user: User) {
        
        var currentUser: TwitterUser?
        
        guard let windowsScenen = UIApplication.shared.connectedScenes.first as? UIWindowScene ,
              let sceneDelegate = windowsScenen.delegate as? SceneDelegate
        else {
            return
        }
        let viewContext = sceneDelegate.context
        
        let userFetch: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        userFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(TwitterUser.userIDString), user.id)
        
        do {
            let results = try viewContext.fetch(userFetch)
            
            if results .count > 0 {
                currentUser = results.first
            } else {
                currentUser = TwitterUser(context: viewContext)
            }
            
            
            currentUser?.userIDString = user.id
            currentUser?.name = user.name
            currentUser?.screenName = user.screenName
            currentUser?.avatar = user.avatarUrlString
            
            currentUser?.following = Int32(user.following ?? 0)
            currentUser?.followed = Int32(user.followed ?? 0)
            currentUser?.isFollowing = user.isFollowing ?? true
            
            //如果是当前用户，则统计推文数量等动态信息
            if user.id == loginUserID {
                let count: Count = Count(context: viewContext)
                count.createdAt = Date()
                count.follower = Int32(user.followed ?? 0)
                count.following = Int32(user.following ?? 0)
                count.tweets = Int32(user.tweetsCount ?? 0)
                
                currentUser?.addToCount(count)
            }
            
            try viewContext.save()
            
        }catch {
            let nsError = error as NSError
            print(nsError.description)
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
    }
    
    func updateCount(user: User) ->[[Int]] {
        
        //参数说明：第一个数组代表follower，第二个代表tweets数量
        //每类有三个数是预留最近一天，最近一周？最近一月？，现在仅使用第一个
        var result: [[Int]] = [[0, 0, 0], [0, 0, 0]]
        
        guard let windowsScenen = UIApplication.shared.connectedScenes.first as? UIWindowScene ,
              let sceneDelegate = windowsScenen.delegate as? SceneDelegate
        else {
            return result
        }
        let viewContext = sceneDelegate.context
        
        let userPredicate: NSPredicate = NSPredicate(format: "%K == %@", #keyPath(Count.countToUser.userIDString), user.id)
        
        let fetchRequest: NSFetchRequest<Count> = Count.fetchRequest()
        fetchRequest.predicate = userPredicate
        
        do {
            let counts = try viewContext.fetch(fetchRequest)
            
//            print(#line, counts.count)
            
            let lastDayCounts = counts.filter{count in
                return abs(count.createdAt?.timeIntervalSinceNow ?? 1000000 ) < 60 * 60 * 24}
            
//            print(#line, lastDayCounts.count)
            
            if let lastDayMax = lastDayCounts.max(by: {a, b in a.follower < b.follower}),
               let lastDayMin = lastDayCounts.max(by: {a, b in a.follower > b.follower}) {
                result[0][0] = Int((lastDayMax.follower - lastDayMin.follower))}
            
            if let lastDayMax = lastDayCounts.max(by: {a, b in a.tweets < b.tweets}),
               let lastDayMin = lastDayCounts.max(by: {a, b in a.tweets > b.tweets}) {
                result[1][0] = Int((lastDayMax.tweets - lastDayMin.tweets))}
            
        } catch let error as NSError {
            print("count not fetched \(error), \(error.userInfo)")
        }
        
        
        return result
    }
}
