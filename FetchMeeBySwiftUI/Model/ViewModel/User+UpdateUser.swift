////
////  AppData+UpdateUser.swift
////  FetchMee
////
////  Created by jyrnan on 2020/10/29.
////  Copyright © 2020 jyrnan. All rights reserved.
////
//
//import SwiftUI
//import Swifter
//import Combine
//import CoreData
//
//extension User {
//    
//    //MARK:-获取用户信息方法
//    
//    
//    /// 更新用户信息的入口
//    func getUserInfo() {
//        var userTag: UserTag
//        
//        ///如果用户已经登陆，且可以读取userDefualt里的IDString（说明已经logined），
//        ///则设置loginUser的userIDString为登陆用户的userIDString
//        if self.isLoggedIn && userDefault.object(forKey: "userIDString") != nil {
//            info.id = userDefault.object(forKey: "userIDString") as! String
//            userTag = UserTag.id(info.id)
//            
//        } else {
//            ///如果用户没用登陆，则根据用户info里面是否有idString或者screenName来生成userTage
//            userTag = info.id != "0000" ? UserTag.id(info.id) : UserTag.screenName(info.screenName ?? "ScreenName")
//        }
//        
//        getUser(userTag: userTag)
//        
//    }
//    
//    /// 获取用户信息，这部分是复用函数，既可以更新loginUser，也可以用来更新任意用户信息
//    /// 如果传入到userIDString是新用户，则会在loingUser .users里创建一个数据并更新
//    /// 更新步骤是首先更新Bio信息，并整体打包赋值给相应的users数据位置
//    /// TODO：增加screenName的参数
//    /// - Parameter userIDString: 用户ID
//    func getUser(userTag: UserTag) {
//        
//        let userTag = userTag
//        var userInfo = UserInfo()
//        
//        ///第一步：
//        /// 更新Bio信息，这部分信息需要从Twitter获取，通过一个成功回调函数来完成赋值
//        /// 回调函数后段会完成继续对其他信息更新的步骤
//        /// - Parameter json: 请求成功获取的JSON信息
//        func getUserBio(json: JSON) {
//            
//            ///userBio信息更新开始
//            userInfo.id = json["id_str"].string!
//            userInfo.name = json["name"].string!
//            userInfo.screenName = "@" + json["screen_name"].string!
//            userInfo.description = json["description"].string!
//            
//            let ct = json["created_at"].string!.split(separator: " ")
//            userInfo.createdAt = " Joined " + String(ct[1]) + " " + String(ct[2]) + " " + String(ct[5]) //加入日期
//            
//            var avatarUrl = json["profile_image_url_https"].string
//            avatarUrl = avatarUrl?.replacingOccurrences(of: "_normal", with: "")
//            imageDownloaderWithClosure(from: avatarUrl, sh: {im in
//                DispatchQueue.main.async {
////                    self.info.avatar = im
//                }
//                
//            })
//            
//            userInfo.bannerUrlString = json["profile_banner_url"].string
//            imageDownloaderWithClosure(from: userInfo.bannerUrlString, sh: {im in
//                DispatchQueue.main.async {
////                    self.info.banner = im
//                }
//            })
//            
//            var loc = json["location"].string ?? "Unknow"
//            if loc != "" {
//                loc = " " + loc
//            }
//            userInfo.loc = loc
//            
//            var url = json["url"].string ?? ""
//            if url != "" {
//                url = " " + url + "\n"
//            }
//            userInfo.url = url
//            
//            userInfo.following = json["friends_count"].integer!
//            userInfo.followed = json["followers_count"].integer!
//            userInfo.isFollowing = json["following"].bool
//            
//            userInfo.notifications = json["notifications"].bool
//            
//            userInfo.tweetsCount = json["statuses_count"].integer!
//            
//            
//            ///从CoreData读取信息计算24小时内新增fo数和推文数量
////            let _ = updateCount(user: userInfo)
//            userInfo.lastDayAddedFollower = Count.updateCount(for: userInfo, in: viewContext).followerOfLastDay
//            userInfo.lastDayAddedTweets = Count.updateCount(for: userInfo, in: viewContext).tweetsOfLastDay
//            
//            ///保存用户信息到CoreData，如果是登陆用户，则保存信息到CoreData
//            if self.isLoggedIn {
//                TwitterUser.updateOrSaveToCoreData(from: json, in: getContext(), isLocalUser: true)
//            }
//            
//            ///信息更新完成，将user数据替换到相应位置
//            self.info = userInfo
//            
//            ///第二步：
//            ///开始更新List相应信息。
//            ///这部分将直接更新users里面的user数据，
//            ///所以需要在上面更新打包完成后才开始
//            ///直接传入上方所获得的user.id
//            ///需要判断当前更新的信息是loginUser的才有必要更新List
//            ///TODO：后续需要更新当前查看用户的list信息
//            
//            getAndUpdateList(userTag: userTag)
//            
//        }
//        
//        ///获取用户基本信息，并生成Bio
////        swifter.showUser(userTag, includeEntities: nil, success: getUserBio(json:), failure: nil)
//    }
//    
//    func getAndUpdateList(userTag: UserTag) {
//        
//        /// 获取用户List信息并更新
//        /// 目前是将List数据直接存储在appData 中
//        /// - Parameter json: 返回的包含list信息的结果
//        func updateList(json: JSON) {
//            
//            let listsJson: [JSON] = json.array!
//            
//            var newLists: [String : ListTag] = [:]
//            for list in listsJson {
//                let name: String = list["name"].string!
//                let idString: String = list["id_str"].string!
//                let listTag = ListTag.id(idString)
//                newLists[name] = listTag
//            }
//            
//            ///比较新老lists名称数据，如果有不同则需要更新
//            if self.lists.keys.sorted() != newLists.keys.sorted() {
//                self.lists = newLists
//            }
//        }
//        
//        
//        //        let userTag = UserTag.id(userIDString)
//        
//        swifter.getSubscribedLists(for: userTag,
//                                   success:updateList)
//    }
//    
//    
//    
//    
//    func follow(userIDString: String) {
//        print(#line, #function)
//        let userTag = UserTag.id(userIDString)
//        swifter.followUser(userTag)
//        self.info.isFollowing = true
//    }
//    
//    func unfollow(userIDString: String) {
//        let userTag = UserTag.id(userIDString)
//        swifter.unfollowUser(userTag)
//        self.info.isFollowing = false
//    }
//    
//    
//    
//    //MARK:-通用的image下载程序
//    
//    /**通用的image下载程序
//     - Parameter urlString: 传入的下载地址
//     - Parameter sh: 传入的闭包用来执行操作，往往用来赋值给数据
//     
//     */
//    func imageDownloaderWithClosure(from urlString: String?, sh: @escaping (UIImage) -> Void ){
//        ///利用这个闭包传入需要的操作，例如赋值
//        ///为了通用，取消了传入闭包在主线程运行的设置，所以需要在各自闭包里面自行设置UI相关命令在主线程执行
//        let sh: (UIImage) -> Void = sh
//        
//        guard urlString != nil  else {return}
//        guard let url = URL(string: urlString!) else { return}
//        let fileName = url.lastPathComponent ///获取下载文件名用于本地存储
//        
//        let cachelUrl = cfh.getPath()
//        let filePath = cachelUrl.appendingPathComponent(fileName, isDirectory: false)
//        
//        ///先尝试获取本地缓存文件
//        if let d = try? Data(contentsOf: filePath) {
//            if let im = UIImage(data: d) {
//                //                DispatchQueue.main.async {
//                sh(im)
//                print(#line, "From local")
//                //                }
//            }
//        } else { //
//            let task = URLSession.shared.downloadTask(with: url) {
//                fileURL, resp, err in
//                if let url = fileURL, let d = try? Data(contentsOf: url) {
//                    if let im = UIImage(data: d) {
//                        try? d.write(to: filePath)
//                        //                        DispatchQueue.main.async {
//                        sh(im)
//                        print(#line, "From remote")
//                        //                        }
//                        
//                    }
//                }
//            }
//            task.resume()
//        }
//    }
//    
//    //MARK:-CoreData part
//
//    func getContext() -> NSManagedObjectContext {
//
//        var viewContext: NSManagedObjectContext!
//
//       if let windowsScenen = UIApplication.shared.connectedScenes.first as? UIWindowScene ,
//              let sceneDelegate = windowsScenen.delegate as? SceneDelegate
//        {
//        viewContext = sceneDelegate.context
//        }
//
//        return viewContext
//    }
////
////
////    /// <#Description#>
////    /// - Parameters:
////    ///   - user: <#user description#>
////    ///   - updateNickName: <#updateNickName description#>
////    func saveOrUpdateUserInfoToCoreData(user: UserInfo, updateNickName: Bool = false) {
////
////        var currentUser: TwitterUser
////
////        guard let windowsScenen = UIApplication.shared.connectedScenes.first as? UIWindowScene ,
////              let sceneDelegate = windowsScenen.delegate as? SceneDelegate
////        else {
////            return
////        }
////        let viewContext = sceneDelegate.context
////
////        let userFetch: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
////        userFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(TwitterUser.userIDString), user.id)
////        userFetch.sortDescriptors = [NSSortDescriptor(keyPath: \TwitterUser.createdAt, ascending: true)]
////
////        do {
////            var results = try viewContext.fetch(userFetch)
////            ///由于重新安装软件时候CoreData还没来得及同步云端的保存的用户信息
////            ///所以在第一次启动时候调用用户信息会保存一个全新的UserInfo到本地CoreData，应用启动会出现一个重复的用户。
////            ///因此需要查询是按照时间排序，如果有重复，就仅保留第一个结果
////
////            if results.count > 0 {
////                currentUser = results.removeFirst()
////
////                if !results.isEmpty {
////                    results.forEach{viewContext.delete($0)}
////                }
////
////
////            } else {
////                currentUser = TwitterUser(context: viewContext)
////            }
////
////            currentUser.createdAt = Date()
////
////            currentUser.userIDString = user.id
////            currentUser.name = user.name
////            currentUser.screenName = user.screenName
////
////            ///如果是本地用户更新信息，则不需要改nickName
////            ///如果需要更改nickName，则需要传入更改参数
////            if updateNickName {
////                currentUser.nickName = user.nickName}
////
////            currentUser.avatar = user.avatarUrlString
////
////            currentUser.following = Int32(user.following ?? 0)
////            currentUser.followed = Int32(user.followed ?? 0)
////            currentUser.isFollowing = user.isFollowing ?? true
////
////            ///如果是当前用户，则统计推文数量等动态信息
////            ///如果是当前登陆用户则将isLoginUser和isLoacluser两项均设置成true
////            ///否则要把isLoginUser设置成false，但是isLocalUser可以不用更改
////            if self.isLoggedIn {
////
////                currentUser.isLocalUser = true
////
////                let count: Count = Count(context: viewContext)
////                count.createdAt = Date()
////                count.follower = Int32(user.followed ?? 0)
////                count.following = Int32(user.following ?? 0)
////                count.tweets = Int32(user.tweetsCount ?? 0)
////
////                currentUser.addToCount(count)
////
////            }
////
////            ///如果nickName是空，且不是本地用户，则从CoreData中删除该用户
////            if user.nickName == "" && currentUser.isLocalUser == false {
////                viewContext.delete(currentUser)
////            }
////
////            try viewContext.save()
////
////        }catch {
////            let nsError = error as NSError
////            print(nsError.description)
////            //            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
////        }
////
////    }
////
////    func updateCount(user: UserInfo) ->[[Int]] {
////
////        //参数说明：第一个数组代表follower，第二个代表tweets数量
////        //每类有三个数是预留最近一天，最近一周？最近一月？，现在仅使用第一个
////        var result: [[Int]] = [[0, 0, 0], [0, 0, 0]]
////
////        guard let windowsScenen = UIApplication.shared.connectedScenes.first as? UIWindowScene ,
////              let sceneDelegate = windowsScenen.delegate as? SceneDelegate
////        else {
////            return result
////        }
////        let viewContext = sceneDelegate.context
////
////        let userPredicate: NSPredicate = NSPredicate(format: "%K == %@", #keyPath(Count.countToUser.userIDString), user.id)
////
////        let fetchRequest: NSFetchRequest<Count> = Count.fetchRequest()
////        fetchRequest.predicate = userPredicate
////
////        do {
////            let counts = try viewContext.fetch(fetchRequest)
////
////            //            print(#line, counts.count)
////
////            let lastDayCounts = counts.filter{count in
////                return abs(count.createdAt?.timeIntervalSinceNow ?? 1000000 ) < 60 * 60 * 24}
////
////            //            print(#line, lastDayCounts.count)
////
////            if let lastDayMax = lastDayCounts.max(by: {a, b in a.follower < b.follower}),
////               let lastDayMin = lastDayCounts.max(by: {a, b in a.follower > b.follower}) {
////                result[0][0] = Int((lastDayMax.follower - lastDayMin.follower))}
////
////            if let lastDayMax = lastDayCounts.max(by: {a, b in a.tweets < b.tweets}),
////               let lastDayMin = lastDayCounts.max(by: {a, b in a.tweets > b.tweets}) {
////                result[1][0] = Int((lastDayMax.tweets - lastDayMin.tweets))}
////
////        } catch let error as NSError {
////            print("count not fetched \(error), \(error.userInfo)")
////        }
////
////
////        return result
////    }
//}
//
