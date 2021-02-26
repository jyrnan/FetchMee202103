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
        
        func getTimeline(timelineType: TimelineType) -> AppState.TimelineData.Timeline {
            switch timelineType {
            case .home: return state.timelineData.home
            case .mention: return state.timelineData.mention
            case .favorite:return state.timelineData.favorite
            case .list(let id, _):return state.timelineData.lists[id]!
            default: return state.timelineData.mention
            }
        }
        
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
            
        case .userRequest(let user):
            appCommand = UserRequstCommand(user: user)
            
        case .updateLoginAccount(let loginUser):
            appState.setting.loginUser = loginUser
            
        case .updateList(let lists):
            appState.setting.lists = lists
            
        case .changeSetting(let setting):
            appState.setting.loginUser?.setting = setting
            
        case .fetchTimeline(let timelineType, let updateMode):
            var timeline: AppState.TimelineData.Timeline!
            switch timelineType {
            case .home:
                timeline = appState.timelineData.home
            case .mention:
                timeline = appState.timelineData.mention
            case .favorite:
                timeline = appState.timelineData.favorite
            case .list(let id, _):
                timeline = appState.timelineData.lists[id]
            default: print("")
            }
            appCommand = FetchTimelineCommand(timeline: timeline, timelineType: timelineType, updateMode: updateMode)
        
        case .fetchTimelineDone(let timeline):
            appState.setting.isProcessingDone = true
            
            switch timeline.type {
            case .home:
                appState.timelineData.home = timeline
            case .mention:
                appState.timelineData.mention = timeline
            case .favorite:
                appState.timelineData.favorite = timeline
            case .list(let id, _):
                appState.timelineData.lists[id] = timeline
            default:
                print("")
            }
        
        case .selectTweetRow(let tweetIDString):
            if appState.timelineData.tweetIDStringOfRowToolsViewShowed == tweetIDString {
                appState.timelineData.tweetIDStringOfRowToolsViewShowed = nil
                } else {
                        appState.timelineData.tweetIDStringOfRowToolsViewShowed = tweetIDString
                }
        
        case .updateNewTweetNumber(let timelineType, let numberOfReadTweet):
            switch timelineType {
            case .home:
                appState.timelineData.home.newTweetNumber -= numberOfReadTweet
            case .mention:
                appState.timelineData.mention.newTweetNumber -= numberOfReadTweet
            case .favorite:
                appState.timelineData.favorite.newTweetNumber -= numberOfReadTweet
            case .list(let id, _):
                appState.timelineData.lists[id]!.newTweetNumber -= numberOfReadTweet
            default:
                print("")
            }
        }
        
        return (appState, appCommand)
    }
}

extension Store {
    
    func getTimeline(timelineType: TimelineType) -> AppState.TimelineData.Timeline {
        switch timelineType {
        case .home:
            return self.appState.timelineData.home
        case .mention:
            return  self.appState.timelineData.mention
        case .favorite:
            return self.appState.timelineData.favorite
        case .list(let id, _):
            return self.appState.timelineData.lists[id] ?? AppState.TimelineData.Timeline()
        default:
            return AppState.TimelineData.Timeline()
    }
}
    
}
