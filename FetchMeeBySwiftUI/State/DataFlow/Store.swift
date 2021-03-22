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
    
    var repository: Repository
    
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
    
    init() {
        self.repository = Repository()
        self.repository.store = self
//        StatusRepository.shared.swifter = swifter
//        UserRepository.shared.swifter = swifter
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
            
        case .updateRequestedUser(let requestedUser ):
            appState.timelineData.requestedUser = requestedUser
            
        case .updateList(let lists):
            appState.setting.lists = lists
            appState.setting.lists.forEach{(id, name) in
                appState.timelineData.timelines[name] = AppState.TimelineData.Timeline(type:.list(id: id, listName: name))
            }
            
        case .changeSetting(let setting):
            appState.setting.loginUser?.setting = setting
            
        case .fetchTimeline(let timelineType, let updateMode):
            appState.setting.isProcessingDone = false
            let timeline: AppState.TimelineData.Timeline = appState.timelineData.getTimeline(timelineType: timelineType)
            appCommand = FetchTimelineCommand(timeline: timeline, timelineType: timelineType, updateMode: updateMode)
        case .fetchTimelineDone(let timeline, let mentionUserData):
            appState.setting.isProcessingDone = true
            appState.timelineData.timelines[timeline.type.rawValue] = timeline
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
            var tweetText = state.setting.checker.tweetText
            tweetText = tweetText.split(separator: " ").dropLast().joined(separator: " ") + " " + text + " "
            appState.setting.checker.tweetText = tweetText
        }
        
        return (appState, appCommand)
    }
}

extension Store {
    func getUser(userID: String, compeletHandler: @escaping (JSON) -> Void) {
//        if let user = repository.users[userID] {
//            compeletHandler(user)
//        } else {
            self.swifter.showUser(UserTag.id(userID),
                                  success: compeletHandler)
//        }
    }
}
