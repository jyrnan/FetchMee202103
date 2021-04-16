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
import AuthenticationServices

protocol AppCommand {
    func execute(in store: Store)
}

extension AppCommand {
    
}

struct LoginCommand: AppCommand {
    let loginUser: User?
    
    func execute(in store: Store) {
        let provider: ASWebAuthenticationPresentationContextProviding = store.provider!
        
        /// 设置swifter的token信息，并获取loginUser的信息
        /// - Parameter loginUser: 传入的已经含有token的用户信息
        func setSwifterAndRequestLoginUser(loginUser: User) {
            
            store.fetcher.setLogined()
            store.dipatch(.userRequest(user: loginUser, isLoginUser: true))
        }
        
        ///传入的lgoinUser有可能是已经保存好的登陆信息
        if loginUser == nil {
            let failureHandler: (Error) -> Void = { error in
                store.dipatch(.alertOn(text: "Login failed", isWarning: true))
            }
            let url = URL(string: "fetchmee://success")!
            store.fetcher.swifter.authorize(withProvider: provider,
                                            callbackURL: url,
                                            success: {token, response in
                                                if let token = token {
                                                    let loginUser = User(id: token.userID!,
                                                                         screenName: token.screenName!,
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
    let user: User
    let isLoginUser: Bool?
    
    func execute(in store: Store) {
        let userTag: UserTag = UserTag.id(user.id)
        
        /// 获取用户信息成功后调用处理用户信息的包
        /// - Parameter json: 返回的用户信息原始数据
        func userHandler(json: JSON) {
            
            
            //信息更新完成，将user数据替换到相应位置并存储
            if isLoginUser == true {
                //保存用户数据到repository,并返回生成的user
                let token = (user.tokenKey, user.tokenSecret) //如果是loginUser，必然有token
                let user = store.repository.addUser(data: json, isLoginUser: isLoginUser, token: token)
                
                store.dipatch(.updateLoginAccount(loginUser: user))
                
            } else {
                let _ = store.repository.addUser(data: json)
                
            }
        }
        //TODO：错误处理方式
        func failureHandler(_ error: Error) ->() {
            store.dipatch(.alertOn(text: error.localizedDescription, isWarning: true))
        }
        
        ///获取用户基本信息，并生成Bio
        store.fetcher.swifter.showUser(userTag, includeEntities: nil, success: userHandler(json:), failure: failureHandler(_:))
        
    }
}

/// 获取login用户的list信息
struct FetchListCommand: AppCommand {
    let user: User
    func execute(in store: Store) {
        
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
            
            ///比较新老lists名称数据，如果有不同并且市LoginUser则需要更新
            guard store.appState.setting.lists.keys.sorted() != newLists.keys.sorted() else {return}
            store.dipatch(.updateList(lists: newLists))
        }
        
        store.fetcher.swifter.getSubscribedLists(for: UserTag.id(user.id), success:listHandler)
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
