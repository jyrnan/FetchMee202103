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
    case update
    
    case alertOn(text: String, isWarning: Bool)
    case alertOff
    
    case setProcessingBegin
    case setProcessingDone
    
    case sendAutoCompleteText(text: String)
    
    case showImageViewer(view: ImageViewer)
    case closeImageViewer
    
    case login(loginUser: User?)
    case userRequest(user: User, isLoginUser: Bool?)
    case updateLoginAccount(loginUser: User?)
    
    case fetchList(user: User)
    case updateList(lists: [String: String])
    
    case changeSetting(setting: UserSetting)
    
    
    case fetchTimeline(timelineType: TimelineType, mode:FetchTimelineCommand.UpdateMode)
    case fetchTimelineDone(timeline: AppState.TimelineData.Timeline, mentionUserData: [User.MentionUser])
    
    case fetchSession(tweetIDString: String)
    case fetchSessionDone(timeline: AppState.TimelineData.Timeline )
    
    case clearTimelineData
    case initialSessionData(status: Status)
    
    case updateNewTweetNumber(timelineType: TimelineType, numberOfReadTweet: Int)
    
    case tweetOperation(operation: TweetCommand.TweetOperation)
    
    case autoComplete(text: String)
    
    case hubStatusRequest
    case updateHubStatus(hubStatus: AppState.TimelineData.HubStatus)
    
    case backgroundClear
}
