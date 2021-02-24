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
            
        case let .updateTimeline(timelineType, updateMode):
            var timeline: [String]
            switch timelineType {
            case .home:
                timeline = appState.timeline.home
            case .mention:
                timeline = appState.timeline.mention
            default: print("")
            }
            appCommand = TimelineCommand(timeline: timeline, updateMode: updateMode)
        }
        
        return (appState, appCommand)
    }
}
