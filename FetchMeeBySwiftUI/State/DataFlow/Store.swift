//
//  Store.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/23.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Combine
import Swifter
import CoreData
import SwiftUI

//Redux下，
//Store可以有多个State，
//Action用来改变State，
//所有的View通过State来获取状态，
//AppCommand或者midware用来获取异步数据，也可以触发Action，
//可以这么理解么？ #Swift

class Store: ObservableObject {
    @Published var appState = AppState()
    
    lazy var swifter: Swifter = {
        if let loginUser = appState.setting.loginUser {
            return Swifter(consumerKey: "wa43gWPPaNLYiZCdvZLXlA",
                           consumerSecret: "BvKyqaWgze9BP3adOSTtsX6PnBOG5ubOwJmGpwh8w",
                           oauthToken: loginUser.tokenKey!,
                           oauthTokenSecret: loginUser.tokenSecret!)
            
        } else {
            return Swifter(consumerKey: "wa43gWPPaNLYiZCdvZLXlA",
                           consumerSecret: "BvKyqaWgze9BP3adOSTtsX6PnBOG5ubOwJmGpwh8w")}}()
    
    var context: NSManagedObjectContext!
    
    private var disposeBag = Set<AnyCancellable>()
    
    func dipatch(_ action: AppAction) {
        #if DEBUG
        print("[ACTION: \(action)")
        #endif
        
        let result = Store.reduce(state: appState, action: action)
        appState = result.0
        if let command = result.1 {
            #if DEBUG
            print("[COMMAND]: \(command)")
            #endif
            command.execute(in: self)
        }
    }
    
    static func reduce(state: AppState, action: AppAction) -> (AppState, AppCommand?) {
        var appState = state
        var appCommand: AppCommand?
        
        switch action {
        
        case .alertOn(let text, let isWarning):
            appState.setting.alert.alertText = text
            appState.setting.alert.isWarning = isWarning
            appState.setting.alert.isPresentedAlert = true
            
        case .alertOff:
            appState.setting.alert.isPresentedAlert = false
            
        case .setProcessingBegin:
            appState.setting.isProcessingDone = false
        case .setProcessingDone:
            appState.setting.isProcessingDone = true
            
        case .login(let authView, let loginUser):
            appCommand = LoginCommand(loginUser: loginUser, presentingFrom: authView)
            
        case .userRequest(let user, let isLoginUser):
            appState.timelineData.timelines[TimelineType.user(userID: "0000").rawValue] = AppState.TimelineData.Timeline(type:TimelineType.user(userID: user.id))
            appCommand = UserRequstCommand(user: user, isLoginUser: isLoginUser)
            
        case .updateLoginAccount(let loginUser):
            appState.setting.loginUser = loginUser
            
        case .updateRequestedUser(let requestedUser ):
            appState.timelineData.requestedUser = requestedUser
        
        case .updateList(let lists):
            appState.setting.lists = lists
            
        case .changeSetting(let setting):
            appState.setting.loginUser?.setting = setting
            
        case .fetchTimeline(let timelineType, let updateMode):
            var timeline: AppState.TimelineData.Timeline {appState.timelineData.timelines[timelineType.rawValue]!}

            appCommand = FetchTimelineCommand(timeline: timeline, timelineType: timelineType, updateMode: updateMode)
        case .fetchTimelineDone(let timeline):
            appState.setting.isProcessingDone = true
            appState.timelineData.timelines[timeline.type.rawValue] = timeline
            
        case .fetchSession(let tweetIDString):
            appState.setting.isProcessingDone = false
            ///先清空原有的缓存，再加入最初推文
            appState.timelineData.timelines[TimelineType.session.rawValue]?.tweetIDStrings.removeAll()
            appState.timelineData.timelines[TimelineType.session.rawValue]?.tweetIDStrings.append(tweetIDString)
            appCommand = FetchSessionCommand(initialTweetIDString: tweetIDString)
        case .fetchSessionDone(let timeline):
            appState.setting.isProcessingDone = true
            appState.timelineData.timelines[TimelineType.session.rawValue] = timeline
     
        case .selectTweetRow(let tweetIDString):
            if appState.timelineData.tweetIDStringOfRowToolsViewShowed == tweetIDString {
                appState.timelineData.tweetIDStringOfRowToolsViewShowed = nil
                } else {
                        appState.timelineData.tweetIDStringOfRowToolsViewShowed = tweetIDString
                }
        
        case .updateNewTweetNumber(let timelineType, let numberOfReadTweet):
            if let newTweetNumber = appState.timelineData.timelines[timelineType.rawValue]?.newTweetNumber,
               newTweetNumber - numberOfReadTweet > 0 {
                appState.timelineData.timelines[timelineType.rawValue]?.newTweetNumber = (newTweetNumber - numberOfReadTweet)
            } else {
                appState.timelineData.timelines[timelineType.rawValue]?.newTweetNumber = 0
            }
                    }
        
        return (appState, appCommand)
    }
}

extension Store {
    
    func getTimeline(timelineType: TimelineType) -> AppState.TimelineData.Timeline {
        return self.appState.timelineData.timelines[timelineType.rawValue] ?? AppState.TimelineData.Timeline()
}
    
}
