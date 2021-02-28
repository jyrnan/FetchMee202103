//
//  AppState.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/23.
//  Copyright © 2021 jyrnan. All rights reserved.
//


import Combine
import Swifter
import SwiftUI

struct AppState {
    var setting = Setting()
    var timelineData = TimelineData()
}

extension AppState {
   
    struct Setting {
        
        struct Alert {
            var isPresentedAlert: Bool = false
            var alertText: String = ""
            var isWarning: Bool = false
        }
        
        var alert = Alert()
        
        var isProcessingDone: Bool = true
        
        var isShowImageViewer: Bool = false //是否浮动显示图片
        var presentedView: AnyView? //通过AnyView就可以实现任意View的传递了？！
        
        ///User及login部分
        @FileStorage(directory: .documentDirectory, fileName: "user.json")
        var loginUser: UserInfo?
        
        var loginRequesting = false
        var loginError: AppError?
        
        var lists: [String: String] = [:] //前面是ID，后面是name
    }
}

extension AppState {
    struct TimelineData {
        struct Timeline {
            var type: TimelineType = .home
            
            var tweetIDStrings: [String] = []
            var newTweetNumber: Int = 0
            
        }
        
        var timelines: [String: Timeline] = [TimelineType.home.rawValue:Timeline(type: .home),
                                         TimelineType.mention.rawValue: Timeline(type: .mention),
                                         TimelineType.favorite.rawValue: Timeline(type: .favorite),
                                         TimelineType.session.rawValue: Timeline(type: .session),
                                         TimelineType.user(userID: "0000").rawValue: Timeline(type: .user(userID: "0000"))]
        
        var tweetIDStringOfRowToolsViewShowed: String?
        var requestedUser: UserInfo = UserInfo()
    }
    
}


