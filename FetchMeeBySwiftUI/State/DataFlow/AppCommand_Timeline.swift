//
//  AppCommand_Timeline.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/24.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Swifter
import SwiftUI

struct FetchTimelineCommand: AppCommand {
    
    enum UpdateMode {
        case top
        case bottom
    }
    
    var timeline: AppState.TimelineData.Timeline
    var timelineType: TimelineType
    var updateMode: UpdateMode
    
    func execute(in store: Store) {
        let token = SubscriptionToken()
        let mentionUserData = store.appState.timelineData.mentionUserData
        
        FetcherSwifter.provider = store.swifter
        let fecher = FetcherSwifter(repository: store.repository)

        fecher.makeSessionUpdataPublisher(updateMode: updateMode, timeline: timeline, mentionUserData: mentionUserData)
            .sink(receiveCompletion: {complete in
                if case .failure(let error) = complete {
                    store.dipatch(.alertOn(text: error.localizedDescription, isWarning: true))
                }
                token.unseal()
            },
            receiveValue: {
                print(#line, #function, $0)
                store.dipatch(.fetchTimelineDone(timeline: $0.0, mentionUserData: $0.1))
                
            })
            .seal(in: token)
    }
}


//MARK:- FetchSessionCommand

struct FetchSessionCommand: AppCommand {
    var initialTweetIDString: String
    
    func execute(in store: Store) {
        var session = AppState.TimelineData.Timeline(type: .session)
        
        func getReplyDetail(for idString: String ) {
            let failureHandler: (Error) -> Void = { error in
                print(#line, error.localizedDescription)}
            
            var counter: Int = 0
            
            func finalReloadView() {
                store.dipatch(.fetchSessionDone(timeline: session))
            }
            func sh(json: JSON) -> () {
                let status:JSON = json
                guard let newTweetIDString = status["id_str"].string else {return}
                
                store.repository.addStatus(data: status)
                store.repository.addUser(data: status["user"])
            
                session.tweetIDStrings.insert(newTweetIDString, at: 0)
                if let in_reply_to_status_id_str = status["in_reply_to_status_id_str"].string, counter < 8 {
                    ///如果推文已经下过在推文仓库可以获取，则直接获取，否则从网络获取
                    if let status = store.repository.status[in_reply_to_status_id_str] {
                        sh(json: status)
                    } else {
                        store.swifter.getTweet(for: in_reply_to_status_id_str, success: sh, failure: failureHandler)
                    }
                    counter += 1
                } else {
                    finalReloadView()
                }
            }
            
            if let status = store.repository.status[initialTweetIDString] {
                sh(json: status) } else {
                    store.swifter.getTweet(for: initialTweetIDString, success: sh, failure: failureHandler)
                }
        }
        
        getReplyDetail(for: initialTweetIDString)
        
    }
    
}

/// 延时选择推文的执行命令
struct DelayedSeletcTweetRowCommand: AppCommand {
    let tweetIDString: String
    func execute(in store: Store) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation{
            store.dipatch(.selectTweetRow(tweetIDString: tweetIDString))
            }
        }
    }
}

/// 设置要通过Toast来在最前面展示的View
struct ClearPresentedView: AppCommand {
    func execute(in store: Store) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            store.appState.setting.presentedView = nil
        }
    }
}
