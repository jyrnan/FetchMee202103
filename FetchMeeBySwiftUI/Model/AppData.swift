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
    lazy var loginUser: User = users[loginUserID] ?? User() //当前用户的信息
    @Published var loginUserID: String = "0000"
    @Published var users: [String: User] = [:] //存储多个用户的信息
    
    @Published var setting: UserSetting = UserSetting() //打算把setting放这里,现在是在SeceneDelegate里面读取

    @Published var isShowUserInfo: Bool = false

    
    @Published var home: Timeline = Timeline(type: .home)
    @Published var mention: Timeline = Timeline(type: .mention)
    @Published var message: Timeline = Timeline(type: .message)
    @Published var favorite: Timeline = Timeline(type: .favorite)
    
    var myUserline: Timeline = Timeline(type: .user) //创建一个自己推文的timeline
    
    let session = URLSession.shared
    
    @Published var isShowingPicture: Bool = false //是否浮动显示图片
    @Published var presentedView: AnyView? //通过AnyView就可以实现任意View的传递了？！
   
}

