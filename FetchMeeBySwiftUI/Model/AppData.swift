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
    @Published var loginUserID: String = "0000"
    @Published var users: [String: User] = [:] //存储多个用户的信息
    
    @Published var setting: UserSetting = UserSetting() //打算把setting放这里,现在是在SeceneDelegate里面读取
    

    @Published var isShowUserInfo: Bool = false

    
    @Published var home: Timeline = Timeline(type: .home)
    @Published var mention: Timeline = Timeline(type: .mention)
    @Published var message: Timeline = Timeline(type: .message)
    @Published var favorite: Timeline = Timeline(type: .favorite)
    ///每次updateUser的时候会刷新生成相应ListTimeline
    @Published var listTimelines: [String : Timeline] = [:]
   
    let session = URLSession.shared
    
    @Published var isShowingPicture: Bool = false //是否浮动显示图片
    @Published var presentedView: AnyView? //通过AnyView就可以实现任意View的传递了？！
    
    //获取记录的用户信息
    lazy var twitterUsers: [TwitterUser] = { () -> [TwitterUser] in
        guard let windowsScenen = UIApplication.shared.connectedScenes.first as? UIWindowScene ,
              let sceneDelegate = windowsScenen.delegate as? SceneDelegate
        else {
            return []
        }
        let viewContext = sceneDelegate.context
        
        let request:NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        
        let twitterUsers = try? viewContext.fetch(request)
        print(#line, "Get TwitterUsers in appData")
        return twitterUsers ?? []
    }()
   
}

