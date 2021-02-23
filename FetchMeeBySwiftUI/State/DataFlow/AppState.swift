//
//  AppState.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/23.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Combine

struct AppState {
    var setting = Setting()
}

extension AppState {
    
    
    
    struct Setting {
        
        struct Alert {
            var isPresentedAlert: Bool = false
            var alertText: String = ""
            var isWarning: Bool = false
        }
        
        var themeColor: ThemeColor = ThemeColor.blue //缺省值是蓝色
        var isIronFansShowed: Bool = false
        var isMediaShowed: Bool = true //控制是否显示图片、视频
        var isDeleteTweets: Bool = false //控制是否删推
        var isKeepRecentTweets: Bool = true //控制是否保留最近推文
        
        var alert = Alert()
        
        ///User及login部分
        
        var loginUser: UserInfo?
        
        var loginRequesting = false
        var loginError: AppError?
    }
}
