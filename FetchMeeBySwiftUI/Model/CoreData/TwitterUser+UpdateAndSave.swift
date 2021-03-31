//
//  TwitterUser.swift
//  FetchMee
//
//  Created by jyrnan on 11/10/20.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import CoreData
import Swifter
import Combine


extension TwitterUser {
    
    /// 更新或新建用户功能
    /// - Parameters:
    ///   - user: 用户基本信息
    ///   - viewContext: moc
    ///   - isLoginUser: 是否当前App用户，如果是则会保留当前的fo等基本信息
    ///   - updateNickName: 是否需要更新当前用户的NickName
    /// - Returns: 返回当前用户
    @discardableResult
    static func updateOrSaveToCoreData(from userJSON: JSON? = nil,
                                       id: String? = "0000",
                                       in viewContext: NSManagedObjectContext = PersistenceContainer.shared.container.viewContext ,
                                       isLocalUser: Bool? = nil,
                                       isLoginUser: Bool? = nil,
                                       isForBookmarkedUser: Bool? = nil,
                                       updateNickName: String? = nil) -> TwitterUser {
        
        func updateTwitterUser(_ currentUser: TwitterUser, with user:JSON) {
            ///设置TwitterUser
            currentUser.createdAt = JSONAdapter().convertToDate(from: user["created_at"].string)
            
            currentUser.userIDString = user["id_str"].string!
            currentUser.name = user["name"].string!
            currentUser.screenName = user["screen_name"].string!
            
            currentUser.avatar = user["profile_image_url_https"].string!
            
            currentUser.following = Int32(user["friends_count"].integer ?? 0)
            currentUser.followed = Int32(user["followers_count"].integer ?? 0)
            currentUser.isFollowing = user["following"].bool ?? true
        }
        
        /// 根据情况查找或新建TwitterUser
        /// - Returns: 返回一个现有或者新建的TwitterUser
        func creatTwitterUser() -> TwitterUser {
            let userID = userJSON?["id_str"].string ?? id!
            let userFetch: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
            userFetch.predicate = NSPredicate(format: "%K = %@", #keyPath(TwitterUser.userIDString), userID)
            userFetch.sortDescriptors = [NSSortDescriptor(keyPath: \TwitterUser.updateTime, ascending: true)]
            
            var results = (try? viewContext.fetch(userFetch)) ?? []
            ///由于重新安装软件时候CoreData还没来得及同步云端的保存的用户信息
            ///所以在第一次启动时候调用用户信息会保存一个全新的UserInfo到本地CoreData，应用启动会出现一个重复的用户。
            ///因此需要查询是按照时间排序，如果有重复，就仅保留第一个结果
            ///TODO:可以通过一个数据库数据合并的功能来实现排除重复
            
            guard results.count > 0 else {
                //如果没有查找到现成User，则新建一个，并设置创建时间
                let newUser = TwitterUser(context: viewContext)
                newUser.updateTime = Date()
                return newUser }
            
                let oldUser = results.removeFirst()
                if !results.isEmpty { results.forEach{viewContext.delete($0)}}
                return oldUser
        }
        
        let currentUser: TwitterUser = creatTwitterUser()

        if let user = userJSON {
        updateTwitterUser(currentUser, with: user)
        }
        
        ///新建非登录本地用户
        if currentUser.userIDString == "0000" {
            currentUser.userIDString = "0000"
            currentUser.name = "FetchMee"
            currentUser.screenName = "FetchMeeApp"
            currentUser.isLocalUser = true
            currentUser.nickName = "Local User"
        }
        
        ///如果是本地用户更新信息，则不需要改nickName
        ///如果需要更改nickName，则需要传入更改参数
        if let nickName = updateNickName {
            currentUser.nickName = nickName
            currentUser.isFavorite = true
        }
        
        ///如果是当前用户，则统计推文数量等动态信息
        ///如果是当前登陆用户则将isLoginUser和isLoacluser两项均设置成true
        ///否则要把isLoginUser设置成false，但是isLocalUser可以不用更改
        if let isLocalUser = isLocalUser {
            currentUser.isLocalUser = isLocalUser
        }
        
        if let isLoginUser = isLoginUser {
            currentUser.isLoginUser = isLoginUser
            
            let count: Count = Count(context: viewContext)
            count.createdAt = Date()
            count.follower = Int32(userJSON?["followers_count"].integer ?? 0)
            count.following = Int32(userJSON?["friends_count"].integer ?? 0)
            count.tweets = Int32(userJSON?["statuses_count"].integer ?? 0)
            
            currentUser.addToCount(count)
        }
        
        
        if let isForBookmarked = isForBookmarkedUser {
            currentUser.isForBookmarked = isForBookmarked }
        
        ///如果nickName是空，且不是本地用户，则从CoreData中删除该用户
        if updateNickName?.count == 0 && currentUser.isLocalUser == false {
            viewContext.delete(currentUser)
        }
        
        if currentUser.updateTime == nil {
            currentUser.updateTime = Date()
        }
        
        do {
            try viewContext.save()
        }catch {
            let nsError = error as NSError
            print(nsError.description)
        }
        
        return currentUser
    }
    
    
}
