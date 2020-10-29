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
   
    func getUser(userIDString: String) {
        let userTag = UserTag.id(userIDString)
        var user = User()
        
        func getUserBio(json: JSON) {
            print(#line, #function)
            user.id = json["id_str"].string!
            user.name = json["name"].string!
            user.screenName = "@" + json["screen_name"].string!
            user.description = json["description"].string!
            
            let ct = json["created_at"].string!.split(separator: " ")
            user.createdAt = " Joined " + String(ct[1]) + " " + String(ct[2]) + " " + String(ct[5]) //加入日期
            
            var avatarUrl = json["profile_image_url_https"].string
            avatarUrl = avatarUrl?.replacingOccurrences(of: "_normal", with: "")
            self.avatarDownloader(from: avatarUrl!)()
            
            user.bannerUrlString = json["profile_banner_url"].string
            if user.bannerUrlString != nil {
                user.banner = UIImage(data: (try? Data(contentsOf: URL(string: user.bannerUrlString!)!)) ?? UIImage(named: "bg")!.pngData()!)
            }
            
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
            
            
            self.users[userIDString] = user
          
            
            //从CoreData读取信息计算24小时内新增fo数和推文数量
            let results = updateCount()
            loginUser.lastDayAddedFollower = results[0][0]
            loginUser.lastDayAddedTweets = results[1][0]
            
            //保存用户信息到CoreData，如果是登陆用户，则传入true
            saveUserInfoToCoreData(id: user.id)
        }
        
        swifter.showUser(userTag, includeEntities: nil, success: getUserBio(json:), failure: nil)
        
    }
    
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
                
            }
        } else { //
            let task = self.session.downloadTask(with: url) {
                fileURL, resp, err in
                if let url = fileURL, let d = try? Data(contentsOf: url) {
                    if let im = UIImage(data: d) {
                    try? d.write(to: filePath)
//                    DispatchQueue.main.async {
                        sh(im)
//                    }
                        
                    }
                }
            }
            task.resume()
        }
    }
    
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
}
