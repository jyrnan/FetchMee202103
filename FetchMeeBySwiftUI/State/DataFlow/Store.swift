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
    
    var repository = Repository()
    var fetcher = FetcherSwifter()
  
    var context: NSManagedObjectContext!
    
    private var disposeBag = Set<AnyCancellable>()
    
    func addObserver() {
        self.appState.setting.tweetInput.autoMapPublisher.sink{text in
            withAnimation{
                self.dipatch(.sendAutoCompleteText(text: text))}
        }.store(in: &disposeBag)
    }
    
    init() {
        self.repository.store = self
        self.fetcher.store = self
        fetcher.setLogined()
        
        addObserver()
    }
    
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
            
        case .showImageViewer(let view):
            appState.setting.presentedView = view
            appState.setting.isShowImageViewer = true
        case .closeImageViewer:
            appState.setting.isShowImageViewer = false
            appCommand = ClearPresentedView()
        
        case .login(let authView, let loginUser):
            appCommand = LoginCommand(loginUser: loginUser, presentingFrom: authView)
            
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
            appCommand = AppCommand_HubStatusRequest() //?
            
        case .changeSetting(let setting):
            
            appState.setting.userSetting = setting
            
        case .fetchTimeline(let timelineType, let updateMode):
            appState.setting.isProcessingDone = false
            let timeline: AppState.TimelineData.Timeline = appState.timelineData.getTimeline(timelineType: timelineType)
            appCommand = FetchTimelineCommand(timeline: timeline, timelineType: timelineType, updateMode: updateMode)
        case .fetchTimelineDone(let timeline, let mentionUserData):
            appState.setting.isProcessingDone = true
            appState.timelineData.timelines[timeline.type.rawValue] = timeline
            //需要更新最新的Mention推文ID备用
            if timeline.type == .mention, timeline.tweetIDStrings.first != nil {
                appState.timelineData.latestMentionID = timeline.tweetIDStrings.first
//                assert(timeline.tweetIDStrings.first != nil)
            }
            appState.timelineData.mentionUserData = mentionUserData
            
            
        case .fetchSession(let tweetIDString):
            appState.setting.isProcessingDone = false
            ///先清空原有的缓存，再加入最初推文
            appState.timelineData.timelines[TimelineType.session.rawValue]?.tweetIDStrings.removeAll()

            appCommand = FetchSessionCommand(initialTweetIDString: tweetIDString)
        case .fetchSessionDone(let timeline):
            appState.setting.isProcessingDone = true
            appState.timelineData.timelines[TimelineType.session.rawValue] = timeline
            
        case .clearTimelineData:
            appState.timelineData.clearTimelineData()
            
        case .selectTweetRow(let tweetIDString):
            appCommand = appState.timelineData.setSelectedRowIndex(tweetIDString: tweetIDString)

        case .deselectTweetRow:
            appState.timelineData.selectedTweetID = nil
            appState.timelineData.deleteFromTimelines(of: "toolsViewMark")
            
        case .updateNewTweetNumber(let timelineType, let numberOfReadTweet):
            appState.timelineData.updateNewTweetNumber(timelineType: timelineType,
                                                       numberOfReadTweet: numberOfReadTweet)
            
        case .tweetOperation(let operatrion):
            appCommand = TweetCommand(operation: operatrion)
         
        case .autoComplete(let text):
            var tweetText = state.setting.tweetInput.tweetText
            tweetText = tweetText.split(separator: " ").dropLast().joined(separator: " ") + " " + text + " "
            appState.setting.tweetInput.tweetText = tweetText
            
            
        case .hubStatusRequest:
            appCommand = AppCommand_HubStatusRequest()
            
        case .updateHubStatus(let hubStatus):
            appState.timelineData.hubStatus = hubStatus
            
        case .backgroundClear:
            appCommand = AppCommand_BGClearTask()

        }
        return (appState, appCommand)
    }
}

extension Store {
    func getUser(userID: String, compeletHandler: @escaping (JSON) -> Void) {
        self.fetcher.swifter.showUser(UserTag.id(userID),
                                  success: compeletHandler)
    }
}
