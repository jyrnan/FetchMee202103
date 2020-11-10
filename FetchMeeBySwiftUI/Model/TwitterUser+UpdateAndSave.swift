//
//  TwitterUser.swift
//  FetchMee
//
//  Created by jyrnan on 11/10/20.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import CoreData


extension TwitterUser {
 
    /// 保存或新建用户功能
    /// - Parameters:
    ///   - user: 用户基本信息
    ///   - viewContext: moc
    ///   - isLoginUser: 是否当前App用户，如果是则会保留当前的fo等基本信息
    ///   - updateNickName: 是否需要更新当前用户的NickName
    /// - Returns: 返回当前用户
    static func updateOrSaveToCoreData(from user: UserInfo, in viewContext: NSManagedObjectContext, isLocalUser: Bool = false, updateNickName: Bool = false) -> TwitterUser {
        
        var currentUser: TwitterUser
        
        let userFetch: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        userFetch.predicate = NSPredicate(format: "%K = %@", #keyPath(TwitterUser.userIDString), user.id)
        userFetch.sortDescriptors = [NSSortDescriptor(keyPath: \TwitterUser.createdAt, ascending: true)]
        
        var results = (try? viewContext.fetch(userFetch)) ?? []
        ///由于重新安装软件时候CoreData还没来得及同步云端的保存的用户信息
        ///所以在第一次启动时候调用用户信息会保存一个全新的UserInfo到本地CoreData，应用启动会出现一个重复的用户。
        ///因此需要查询是按照时间排序，如果有重复，就仅保留第一个结果
        ///TODO:可以通过一个数据库数据合并的功能来实现排除重复
        
        if results.count > 0 {
            currentUser = results.removeFirst()
            
            if !results.isEmpty { results.forEach{viewContext.delete($0)}}
        } else {currentUser = TwitterUser(context: viewContext)}
        
        currentUser.createdAt = Date()
        
        currentUser.userIDString = user.id
        currentUser.name = user.name
        currentUser.screenName = user.screenName
        
        ///如果是本地用户更新信息，则不需要改nickName
        ///如果需要更改nickName，则需要传入更改参数
        if updateNickName {
            currentUser.nickName = user.nickName}
        
        currentUser.avatar = user.avatarUrlString
        
        currentUser.following = Int32(user.following ?? 0)
        currentUser.followed = Int32(user.followed ?? 0)
        currentUser.isFollowing = user.isFollowing ?? true
        
        ///如果是当前用户，则统计推文数量等动态信息
        ///如果是当前登陆用户则将isLoginUser和isLoacluser两项均设置成true
        ///否则要把isLoginUser设置成false，但是isLocalUser可以不用更改
        if isLocalUser {
            
            currentUser.isLocalUser = true
            
            let count: Count = Count(context: viewContext)
            count.createdAt = Date()
            count.follower = Int32(user.followed ?? 0)
            count.following = Int32(user.following ?? 0)
            count.tweets = Int32(user.tweetsCount ?? 0)
            
            currentUser.addToCount(count)
            print(#line, "add user count info")
        }
        
        ///如果nickName是空，且不是本地用户，则从CoreData中删除该用户
        if user.nickName?.count == 0 && currentUser.isLocalUser == false {
            viewContext.delete(currentUser)
        }
        do {
            try viewContext.save()
            
        }catch {
            let nsError = error as NSError
            print(nsError.description)
            //            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        
        return currentUser
    }
}
