//
//  AppAction.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/23.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Swifter
import SwiftUI

enum AppAction {
    case alertOn(text: String, isWarning: Bool)
    case alertOff
    
    case setProcessingBegin
    case setProcessingDone
    
    case showImageViewer(view: AnyView)
    case closeImageViewer
    
    case login(presentingFrom: AuthViewController, loginUser: UserInfo?)
    case userRequest(user: UserInfo, isLoginUser:  Bool = true)
    case updateLoginAccount(loginUser: UserInfo?)
    case updateRequestedUser(requestedUser: UserInfo)
    
    case updateList(lists: [String: String])
    
    case changeSetting(setting: UserSetting)
    
    
    case fetchTimeline(timelineType: TimelineType, mode:FetchTimelineCommand.UpdateMode)
    case fetchTimelineDone(timeline: AppState.TimelineData.Timeline)
    
    case fetchSession(tweetIDString: String)
    case fetchSessionDone(timeline: AppState.TimelineData.Timeline )
    
    case clearTimelineData
    
    case selectTweetRow(tweetIDString: String)
    case deselectTweetRow
    
    case updateNewTweetNumber(timelineType: TimelineType, numberOfReadTweet: Int)
    
    case tweetOperation(operation: TweetCommand.Operation, tweetIDString: String)
}
