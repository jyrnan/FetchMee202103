//
//  AppCommand.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/23.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Combine
import Swifter
import CoreData

protocol AppCommand {
    func execute(in store: Store)
}

struct LoginCommand: AppCommand {
    var loginUser: UserInfo?
    let presentingFrom: AuthViewController
    
    func execute(in store: Store) {
        let store = store
        
        func updateLoginUser(loginUser: UserInfo) {
            guard let tokenKey = loginUser.tokenKey,
                  let tokenSecret = loginUser.tokenSecret else { return }
            
            store.swifter = Swifter(consumerKey: "wa43gWPPaNLYiZCdvZLXlA",
                                    consumerSecret: "BvKyqaWgze9BP3adOSTtsX6PnBOG5ubOwJmGpwh8w",
                                    oauthToken: tokenKey,
                                    oauthTokenSecret: tokenSecret)
            
            store.dipatch(.userRequest(user: loginUser))
        }
        
        ///传入的lgoinUser有可能是已经保存好的登陆信息
        if loginUser == nil {
            let failureHandler: (Error) -> Void = { error in
                print(error.localizedDescription)
            }
            let url = URL(string: "fetchmee://success")!
            store.swifter.authorize(withCallback: url,
                                    presentingFrom:presentingFrom,
                                    success: {token, response in
                                        if let token = token {
                                            let loginUser = UserInfo(id: token.userID!,
                                                                     screenName: token.screenName,
                                                                     tokenKey: token.key,
                                                                     tokenSecret: token.secret)
                                            
                                            updateLoginUser(loginUser: loginUser)}},
                                    failure: failureHandler)
        } else {
            updateLoginUser(loginUser: loginUser!)
        }
    }
}


//MARK:-获取用户信息
struct UserRequstCommand: AppCommand {
    var user: UserInfo
    
    func execute(in store: Store) {
        let userTag: UserTag = UserTag.id(user.id)
        
        func userHandler(json: JSON) {
            UserRepository.shared.addUser(json)
            
            TwitterUser.updateOrSaveToCoreData(from: json,
                                               in: store.context,
                                               isLocalUser: true)
            
            var updatedUser = updateUser(update: user, with: json)
            updatedUser = updateUser(update: updatedUser, from: store.context)
            
            ///信息更新完成，将user数据替换到相应位置
            store.dipatch(.updateLoginAccount(loginUser: updatedUser))
            
            //Test
            store.dipatch(.alertOn(text: "Updated user", isWarning: true))
        }
        
        /// 获取用户List信息并更新
        /// 目前是将List数据直接存储在appState 中
        /// - Parameter json: 返回的包含list信息的结果
        func listHandler(json: JSON) {
            let listsJson: [JSON] = json.array!
            
            var newLists: [String : ListTag] = [:]
            listsJson.forEach{newLists[$0["name"].string!] = ListTag.id($0["id_str"].string!)}
            
            ///比较新老lists名称数据，如果有不同则需要更新
            guard store.appState.setting.lists.keys.sorted() != newLists.keys.sorted() else {return}
            store.dipatch(.updateList(lists: newLists))
            
        }
        
        ///获取用户基本信息，并生成Bio
        store.swifter.showUser(userTag, includeEntities: nil, success: userHandler(json:), failure: nil)
        store.swifter.getSubscribedLists(for: userTag, success:listHandler)
    }
}

extension UserRequstCommand {
    func updateUser(update userInfo:  UserInfo, with json: JSON) -> UserInfo {
        var userInfo = userInfo
        
        ///userBio信息更新开始
        userInfo.id = json["id_str"].string!
        userInfo.name = json["name"].string!
        userInfo.screenName = "@" + json["screen_name"].string!
        userInfo.description = json["description"].string!
        
        let ct = json["created_at"].string!.split(separator: " ")
        userInfo.createdAt = " Joined " + String(ct[1]) + " " + String(ct[2]) + " " + String(ct[5]) //加入日期
        
        var avatarUrl = json["profile_image_url_https"].string
        avatarUrl = avatarUrl?.replacingOccurrences(of: "_normal", with: "")
        userInfo.bannerUrlString = json["profile_banner_url"].string
        
        var loc = json["location"].string ?? "Unknow"
        if loc != "" {
            loc = " " + loc
        }
        userInfo.loc = loc
        
        var url = json["url"].string ?? ""
        if url != "" {
            url = " " + url + "\n"
        }
        userInfo.url = url
        
        userInfo.following = json["friends_count"].integer!
        userInfo.followed = json["followers_count"].integer!
        userInfo.isFollowing = json["following"].bool
        
        userInfo.notifications = json["notifications"].bool
        
        userInfo.tweetsCount = json["statuses_count"].integer!
        
        return userInfo
    }
    
    func updateUser(update userInfo: UserInfo, from context: NSManagedObjectContext) -> UserInfo {
        ///从CoreData读取信息计算24小时内新增fo数和推文数量
        var userInfo = userInfo
        
        userInfo.lastDayAddedFollower = Count.updateCount(for: userInfo, in: context).followerOfLastDay
        userInfo.lastDayAddedTweets = Count.updateCount(for: userInfo, in: context).tweetsOfLastDay
        
        return userInfo
    }
}
