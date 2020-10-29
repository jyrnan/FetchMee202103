//
//  User.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/15.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine
import CoreData


class AppData: ObservableObject {
   
    @Published var isLoggedIn: Bool = false
    @Published var loginUser: User = User() //当前用户的信息
    @Published var userStore: [String: User] = [:] //存储多个用户的信息
    @Published var userStringMark: [String: Int] = [:] // 用户互动数量纪录
    @Published var isShowUserInfo: Bool = false
    
    @Published var home: Timeline = Timeline(type: .home)
    @Published var mention: Timeline = Timeline(type: .mention)
    @Published var message: Timeline = Timeline(type: .message)
    @Published var favorite: Timeline = Timeline(type: .favorite)
    
    var myUserline: Timeline = Timeline(type: .user) //创建一个自己推文的timeline
    
    let session = URLSession.shared
    
    //CoreData part
    let viewContext = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.delegate as? SceneDelegate)?.context
    
    @Published var isShowingPicture: Bool = false //是否浮动显示图片
    @Published var presentedView: AnyView? //通过AnyView就可以实现任意View的传递了？！
    
    
    //MARK:-获取用户信息方法
    func getMyInfo() {
        
        var userTag: UserTag?
        if let screenName = self.loginUser.screenName {
            userTag = UserTag.screenName(String(screenName.dropFirst())) //去掉前面的@符号
        } else {
            //如果没有设置用户ID，且可以读取userDefualt里的IDString（说明已经logined），则设置loginUser的userIDString为登陆用户的userIDString
            if self.loginUser.id == "0000" && userDefault.object(forKey: "userIDString") != nil {
                self.loginUser.id = userDefault.object(forKey: "userIDString") as! String
            }
            userTag = UserTag.id(self.loginUser.id)
        }
        
        //读取用户设置信息
        loginUser.setting.load()
        
        guard userTag != nil else {return}
        getUserInfo(for: userTag!)
    }
    
    func getUserInfo(for userTag: UserTag) {
        print(#line, #function)
        print(userTag)
        swifter.showUser(userTag, includeEntities: nil, success: getUserBio(json:), failure: nil)
        swifter.getSubscribedLists(for: userTag, success: updateList, failure: nil)
    }
    
    
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
        
        self.loginUser.lists = newLists
        
        
    }
    
    //获取用户信息
    func getUserBio(json: JSON) {
        print(#line, #function)
        self.loginUser.id = json["id_str"].string!
        self.loginUser.name = json["name"].string!
        self.loginUser.screenName = "@" + json["screen_name"].string!
        self.loginUser.description = json["description"].string!
        
        let ct = json["created_at"].string!.split(separator: " ")
        self.loginUser.createdAt = " Joined " + String(ct[1]) + " " + String(ct[2]) + " " + String(ct[5]) //加入日期
        
        var avatarUrl = json["profile_image_url_https"].string
        avatarUrl = avatarUrl?.replacingOccurrences(of: "_normal", with: "")
        self.avatarDownloader(from: avatarUrl!)()
        
        self.loginUser.bannerUrlString = json["profile_banner_url"].string
        if self.loginUser.bannerUrlString != nil {
            self.loginUser.banner = UIImage(data: (try? Data(contentsOf: URL(string: self.loginUser.bannerUrlString!)!)) ?? UIImage(named: "bg")!.pngData()!)
        }
        
        var loc = json["location"].string ?? "Unknow"
        if loc != "" {
            loc = " " + loc
        }
        self.loginUser.loc = loc
        
        var url = json["url"].string ?? ""
        if url != "" {
            url = " " + url + "\n"
        }
        self.loginUser.url = url
        
        self.loginUser.following = json["friends_count"].integer!
        self.loginUser.followed = json["followers_count"].integer!
        self.loginUser.isFollowing = json["following"].bool
        
        self.loginUser.notifications = json["notifications"].bool
        
        self.loginUser.tweetsCount = json["statuses_count"].integer!
        
        //保存用户信息到CoreData，如果是登陆用户，则传入true
        saveUserInfoToCoreData(id: self.loginUser.id, isLoginUser: self.isLoggedIn)
        
        //从CoreData读取信息计算24小时内新增fo数和推文数量
        let results = updateCount()
        loginUser.lastDayAddedFollower = results[0][0]
        loginUser.lastDayAddedTweets = results[1][0]
    }
    
    func follow() {
        print(#line, #function)
        let userTag = UserTag.id(self.loginUser.id)
        swifter.followUser(userTag)
        self.loginUser.isFollowing = true
    }
    
    func unfollow() {
        let userTag = UserTag.id(self.loginUser.id)
        swifter.unfollowUser(userTag)
        self.loginUser.isFollowing = false
    }
    
    func avatarDownloader(from urlString: String) -> () -> () {
        return{
            
            let url = URL(string: urlString)!
            let fileName = url.lastPathComponent //获取下载文件名用于本地存储
            
            let cachelUrl = cfh.getPath()
            let filePath = cachelUrl.appendingPathComponent(fileName, isDirectory: false)
            
            //先尝试获取本地缓存文件
            if let d = try? Data(contentsOf: filePath) {
                if let im = UIImage(data: d) {
                    DispatchQueue.main.async {
                        self.loginUser.avatar = im
                        
                    }
                }
            } else {
                let task = self.session.downloadTask(with: url) {
                    fileURL, resp, err in
                    if let url = fileURL, let d = try? Data(contentsOf: url) {
                        let im = UIImage(data: d)
                        try? d.write(to: filePath)
                        DispatchQueue.main.async {
                            self.loginUser.avatar = im
                        }
                    }
                }
                task.resume()
            }
        }
    }
}


extension AppData {
    
    func saveUserInfoToCoreData(id: String, isLoginUser: Bool = false) {
        
        var currentUser: TwitterUser?
        
        guard let windowsScenen = UIApplication.shared.connectedScenes.first as? UIWindowScene ,
              let sceneDelegate = windowsScenen.delegate as? SceneDelegate
        else {
            return
        }
        let viewContext = sceneDelegate.context
        
        let userFetch: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        userFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(TwitterUser.userIDString), id)
        
        do {
            let results = try viewContext.fetch(userFetch)
            
            if results .count > 0 {
                currentUser = results.first
            } else {
                currentUser = TwitterUser(context: viewContext)
            }
            
            
            currentUser?.userIDString = id
            currentUser?.name = loginUser.name
            currentUser?.screenName = loginUser.screenName
            currentUser?.avatar = loginUser.avatarUrlString
            
            currentUser?.following = Int32(loginUser.following ?? 0)
            currentUser?.followed = Int32(loginUser.followed ?? 0)
            currentUser?.isFollowing = loginUser.isFollowing ?? true
            
            //如果是当前用户，则统计推文数量等动态信息
            if isLoginUser {
            let count: Count = Count(context: viewContext)
            count.createdAt = Date()
            count.follower = Int32(loginUser.followed ?? 0)
            count.following = Int32(loginUser.following ?? 0)
            count.tweets = Int32(loginUser.tweetsCount ?? 0)
            
            currentUser?.addToCount(count)
            }
            
            try viewContext.save()
            
        }catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
    }
    
    func updateCount() ->[[Int]] {
        
        //参数说明：第一个数组代表follower，第二个代表tweets数量
        //每类有三个数是预留最近一天，最近一周？最近一月？，现在仅使用第一个
        var result: [[Int]] = [[0, 0, 0], [0, 0, 0]]
        
        guard let windowsScenen = UIApplication.shared.connectedScenes.first as? UIWindowScene ,
              let sceneDelegate = windowsScenen.delegate as? SceneDelegate
        else {
            return result
        }
        let viewContext = sceneDelegate.context
        
        let userPredicate: NSPredicate = NSPredicate(format: "%K == %@", #keyPath(Count.countToUser.userIDString), loginUser.id)
        
        let fetchRequest: NSFetchRequest<Count> = Count.fetchRequest()
        fetchRequest.predicate = userPredicate
        
        do {
            let counts = try viewContext.fetch(fetchRequest)
            
            print(#line, counts.count)
            
            let lastDayCounts = counts.filter{count in
                return abs(count.createdAt?.timeIntervalSinceNow ?? 1000000 ) < 60 * 60 * 24}
            
            print(#line, lastDayCounts.count)
            
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
