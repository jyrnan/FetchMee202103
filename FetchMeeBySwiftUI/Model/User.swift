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


class User: ObservableObject {
   
    @Published var isLoggedIn: Bool = false
    @Published var info: UserInfo = UserInfo() //用户的基本信息
    @Published var lists: [String: ListTag] = [:]

    @Published var setting: UserSetting = UserSetting() //打算把setting放这里,现在是在SeceneDelegate里面读取
    
    @Published var isShowingPicture: Bool = false //是否浮动显示图片
    @Published var presentedView: AnyView? //通过AnyView就可以实现任意View的传递了？！

}

