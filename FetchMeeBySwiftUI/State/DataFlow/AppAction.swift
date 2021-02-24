//
//  AppAction.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/23.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Swifter

enum AppAction {
    case alertOn(text: String, isWarning: Bool)
    case alertOff
    
    case login(presentingFrom: AuthViewController, loginUser: UserInfo?)
    case userRequest(user: UserInfo)
    case updateLoginAccount(loginUser: UserInfo?)
    
    case updateList(lists: [String: ListTag])
    
    case changeSetting(setting: UserSetting)
    
    
    case updateTimeline(timeline: TimelineType, mode:TimelineCommand.UpdateMode)
}
