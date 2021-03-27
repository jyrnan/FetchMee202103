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
    let loginUser: UserInfo?
    let presentingFrom: AuthViewController
    
    func execute(in store: Store) {
        
        /// 设置swifter的token信息，并获取loginUser的信息
        /// - Parameter loginUser: 传入的已经含有token的用户信息
        func setSwifterAndRequestLoginUser(loginUser: UserInfo) {
//            guard let tokenKey = loginUser.tokenKey,
//                  let tokenSecret = loginUser.tokenSecret else { return }
            
//            store.swifter = Swifter(consumerKey: "wa43gWPPaNLYiZCdvZLXlA",
//                                    consumerSecret: "BvKyqaWgze9BP3adOSTtsX6PnBOG5ubOwJmGpwh8w",
//                                    oauthToken: tokenKey,
//                                    oauthTokenSecret: tokenSecret)
            store.fetcher.setLogined()
            
            store.dipatch(.userRequest(user: loginUser))
        }
        
        ///传入的lgoinUser有可能是已经保存好的登陆信息
        if loginUser == nil {
            let failureHandler: (Error) -> Void = { error in
                store.dipatch(.alertOn(text: "Login failed", isWarning: true))
            }
            let url = URL(string: "fetchmee://success")!
            store.fetcher.swifter.authorize(withCallback: url,
                                    presentingFrom:presentingFrom,
                                    success: {token, response in
                                        if let token = token {
                                            let loginUser = UserInfo(id: token.userID!,
                                                                     screenName: token.screenName,
                                                                     tokenKey: token.key,
                                                                     tokenSecret: token.secret)
                                            
                                            setSwifterAndRequestLoginUser(loginUser: loginUser)}},
                                    failure: failureHandler)
        } else {
            setSwifterAndRequestLoginUser(loginUser: loginUser!)
        }
    }
}


//MARK:-获取用户信息
struct UserRequstCommand: AppCommand {
    let user: UserInfo
    let isLoginUser: Bool
    
    func execute(in store: Store) {
        var updatedUser = user
        let userTag: UserTag = UserTag.id(user.id)
        
        /// 获取用户信息成功后调用处理用户信息的包
        /// - Parameter json: 返回的用户信息原始数据
        func userHandler(json: JSON) {
            store.repository.addUser(data: json)
            
            updateUser(update: &updatedUser, with: json)
            updateUser(update: &updatedUser, from: store.context)
            
            ///信息更新完成，将user数据替换到相应位置并存储
            if isLoginUser {
                store.dipatch(.updateLoginAccount(loginUser: updatedUser))
                store.dipatch(.alertOn(text: "Updated", isWarning: false))
                
                ///如果是login用户，则将其信息存入到CoreData中备用
                TwitterUser.updateOrSaveToCoreData(from: json,
                                                   in: store.context,
                                                   isLocalUser: true)
            } else {
                store.dipatch(.updateRequestedUser(requestedUser: updatedUser))
                store.dipatch(.fetchTimeline(timelineType: .user(userID: user.id), mode: .top))
            }
        }
        
        /// 获取用户List信息并更新
        /// 目前是将List数据直接存储在appState 中
        /// - Parameter json: 返回的包含list信息的结果
        func listHandler(json: JSON) {
            let listsJson: [JSON] = json.array!
            var newLists: [String : String] = [:]
            listsJson.forEach{json in
                let name = json["name"].string!
                let id = json["id_str"].string!
                newLists[id] = name
            }
            
            ///比较新老lists名称数据，如果有不同则需要更新
            guard store.appState.setting.lists.keys.sorted() != newLists.keys.sorted() && isLoginUser else {return}
            store.dipatch(.updateList(lists: newLists))
            
        }
        
        func failureHandler(_ error: Error) ->() {
            store.dipatch(.alertOn(text: error.localizedDescription, isWarning: true))
        }
        
        ///获取用户基本信息，并生成Bio
        store.fetcher.swifter.showUser(userTag, includeEntities: nil, success: userHandler(json:), failure: failureHandler(_:))
        store.fetcher.swifter.getSubscribedLists(for: userTag, success:listHandler)
        
    }
}

extension UserRequstCommand {
    
    /// User信息转换的接口程序
    /// - Parameters:
    ///   - userInfo: 输入的初始用户信息
    ///   - json: 输入的用户原始数据
    /// - Returns: 输出的用户信息
    func updateUser(update userInfo: inout UserInfo, with json: JSON) {
        //        var userInfo = userInfo
        
        ///userBio信息更新开始
        userInfo.id = json["id_str"].string!
        userInfo.name = json["name"].string!
        userInfo.screenName = "@" + json["screen_name"].string!
        userInfo.description = json["description"].string!
        
        let ct = json["created_at"].string!.split(separator: " ")
        userInfo.createdAt = " Joined " + String(ct[1]) + " " + String(ct[2]) + " " + String(ct[5]) //加入日期
        
        var avatarUrl = json["profile_image_url_https"].string
        avatarUrl = avatarUrl?.replacingOccurrences(of: "_normal", with: "")
        userInfo.avatarUrlString = avatarUrl
        
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
        
    }
    
    func updateUser(update userInfo: inout UserInfo, from context: NSManagedObjectContext) {
        ///从CoreData读取信息计算24小时内新增fo数和推文数量
        
        userInfo.lastDayAddedFollower = Count.updateCount(for: userInfo).0.first
        userInfo.lastDayAddedTweets = Count.updateCount(for: userInfo).1.first
        
    }
}

class SubscriptionToken {
    var cancellable: AnyCancellable?
    func unseal() { cancellable = nil }
}

extension AnyCancellable {
    func seal(in token: SubscriptionToken) {
        token.cancellable = self
    }
}
