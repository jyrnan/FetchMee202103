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
    
    case setProcessingBegin
    case setProcessingDone
    
    case login(presentingFrom: AuthViewController, loginUser: UserInfo?)
    case userRequest(user: UserInfo)
    case updateLoginAccount(loginUser: UserInfo?)
    
    case updateList(lists: [String: String])
    
    case changeSetting(setting: UserSetting)
    
    
    case fetchTimeline(timelineType: TimelineType, mode:FetchTimelineCommand.UpdateMode)
    case fetchTimelineDone(timeline: AppState.TimelineData.Timeline)
    
    case fetchSession(tweetIDString: String)
    case fetchSessionDone(timeline: AppState.TimelineData.Timeline )
    
    case selectTweetRow(tweetIDString: String)
    
    case updateNewTweetNumber(timelineType: TimelineType, numberOfReadTweet: Int)
}
