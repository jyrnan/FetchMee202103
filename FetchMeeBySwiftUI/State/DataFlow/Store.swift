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
import AuthenticationServices

//Redux下，
//Store可以有多个State，
//Action用来改变State，
//所有的View通过State来获取状态，
//AppCommand用来获取异步数据，也可以触发Action，
//可以这么理解么？ #Swift

class Store: ObservableObject {
    @Published var appState = AppState()
    
    var fetcher = FetcherSwifter()
  
    var context: NSManagedObjectContext = PersistenceContainer.shared.container.viewContext
    var provider:ASWebAuthenticationPresentationContextProviding = AuthProvider()
    
    private var disposeBag = Set<AnyCancellable>()
    
    private func addObserver() {
        self.appState.setting.tweetInput.autoMapPublisher.sink{text in
            withAnimation{
                self.dispatch(.sendAutoCompleteText(text: text))}
        }.store(in: &disposeBag)
    }
    
    init() {
        self.fetcher.store = self
        fetcher.setLogined()
        
        addObserver()
        dispatch(.addUserCDToStore)
    }
    
    func dispatch(_ action: AppAction) {
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
        case .update:
            print("only update")
        
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
            
        case .sendAutoCompleteText(let text):
            appState.setting.autoCompleteText = text
            
        case .login(let loginUser):
            appCommand = LoginCommand(loginUser: loginUser)
            
        case .userRequest(let user, let isLoginUser):
            appState.timelineData.timelines[TimelineType.user(userID: user.id).rawValue] = AppState.TimelineData.Timeline(type:TimelineType.user(userID: user.id))
            appCommand = UserRequstCommand(user: user, isLoginUser: isLoginUser)
            
        case .updateLoginAccount(let loginUser):
            appState.setting.loginUser = loginUser
            guard  let user = loginUser else { return (appState, appCommand) }
            appCommand = FetchListCommand(user: user)
            
        case .fetchList(let user):
            appCommand = FetchListCommand(user: user)
            
        case .updateList(let lists):
            appState.setting.lists = lists
            appState.setting.lists.forEach{(id, name) in
                appState.timelineData.timelines[name] = AppState.TimelineData.Timeline(type:.list(id: id, listName: name))
            }
            appCommand = HubStatusRequestCommand() //?
            
        case .changeSetting(let setting):
            appState.setting.userSetting = setting
            
        case .fetchTimeline(let timelineType, let updateMode):
            appState.setting.isProcessingDone = false
            let timeline: AppState.TimelineData.Timeline = appState.timelineData.getTimeline(timelineType: timelineType)
            let mentionUserData = appState.timelineData.mentionUserData
            let statuses = appState.timelineData.statuses
            let users = appState.timelineData.users
            appCommand = FetchTimelineCommand(timeline: timeline, timelineType: timelineType, updateMode: updateMode, mentionUserData: mentionUserData, statuses: statuses, users: users)
        
        case .fetchTimelineDone(let timeline, let mentionUserData, let statuses, let users):
            appState.setting.isProcessingDone = true
            appState.timelineData.timelines[timeline.type.rawValue] = timeline
            //需要更新最新的Mention推文ID备用
            if timeline.type == .mention, timeline.tweetIDStrings.first != nil {
                appState.timelineData.latestMentionID = timeline.tweetIDStrings.first
            }
            appState.timelineData.mentionUserData = mentionUserData
            appState.timelineData.statuses = statuses
            appState.timelineData.users = users

//        case .fetchSession(let tweetIDString):
//            appState.setting.isProcessingDone = false
//            ///先清空原有的缓存，再加入最初推文
//            appState.timelineData.timelines[TimelineType.session.rawValue]?.tweetIDStrings.removeAll()
//            appCommand = FetchSessionCommand(initialTweetIDString: tweetIDString)
            
        case .fetchSessionDone(let timeline, let statuses, let users):
            appState.setting.isProcessingDone = true
            appState.timelineData.timelines[TimelineType.session.rawValue] = timeline
            appState.timelineData.statuses.merge(statuses) {_, new in new}
            appState.timelineData.users.merge(users) {_, new in new}
            
        case .clearTimelineData:
            appState.timelineData.clearTimelineData()
            
        case .initialAndFetchSessionData(let status):
            appState.setting.isProcessingDone = false
            appState.timelineData.initialSessionData(with: status)
            appCommand = FetchSessionCommand(initialTweetIDString: status.id)
            
        case .updateNewTweetNumber(let timelineType, let numberOfReadTweet):
            appState.timelineData.updateNewTweetNumber(timelineType: timelineType,
                                                       numberOfReadTweet: numberOfReadTweet)
            
        case .tweetOperation(let operatrion):
            appCommand = TweetCommand(operation: operatrion)
            
        case .tweetOperationDone(let timelineData):
            appState.timelineData = timelineData
         
        case .autoComplete(let text):
            var tweetText = state.setting.tweetInput.tweetText
            tweetText = tweetText.split(separator: " ").dropLast().joined(separator: " ") + " " + text + " "
            appState.setting.tweetInput.tweetText = tweetText
            
            
        case .hubStatusRequest:
            appCommand = HubStatusRequestCommand()
            
        case .updateHubStatus(let hubStatus):
            appState.timelineData.hubStatus = hubStatus
            
        case .addUserCDToStore:
            appCommand = AddUserCDToStoreCommand()
            
        case .updateUsers(let users):
            appState.timelineData.users = users
            
        case .backgroundClear:
            appCommand = BGClearTask()

        }
        return (appState, appCommand)
    }
}

