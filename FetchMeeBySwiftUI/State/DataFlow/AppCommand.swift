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
            
            store.repository.adapter.convertAndUpdateUser(update: &updatedUser, with: json)
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
