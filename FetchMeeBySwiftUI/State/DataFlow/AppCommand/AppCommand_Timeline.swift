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
        
        store.fetcher.makeSessionUpdatePublisher(updateMode: updateMode, timeline: timeline, mentionUserData: mentionUserData)
            .sink(receiveCompletion: {complete in
                if case .failure(let error) = complete {
                    store.dispatch(.alertOn(text: error.localizedDescription, isWarning: true))
                }
                token.unseal()
            },
            receiveValue: {
                store.dispatch(.fetchTimelineDone(timeline: $0.0, mentionUserData: $0.1))
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
                
                session.status = session.tweetIDStrings.map{store.repository.getStatus(byID: $0)}
                store.dispatch(.fetchSessionDone(timeline: session))
            }
            
            func getStatus(id: String) {
                
                //如果status能直接从repository获取，则直接获取
                if let status = store.repository.statuses[id] {
                
                    //直接获取status后，查看是否需要进一步获取后续status
                    if let nextID = status.in_reply_to_status_id_str {
                        
                        session.tweetIDStrings.insert(nextID, at: 0)
                        getStatus(id: nextID)
                    }
                    //没有后续回复数据，所以结束
                    else {
                        finalReloadView()
                    }
                }
                //不能直接获取status， 所以从网咯获取
                else {
                    counter += 1
                    store.fetcher.swifter.getTweet(for: id, success: sh, failure: failureHandler)
                }
            }
            
            func sh(json: JSON) -> () {
                let status:JSON = json
                
                store.repository.addStatus(data: status)
                let _ = store.repository.addUser(data: status["user"])
                
                
                if let nextID = status["in_reply_to_status_id_str"].string, counter < 8 {
                    //如果推文还有回复的ID，并且网络总获取次数小于8
                    //则继续从网咯获取
                    //先加入ID再获取Status
                    session.tweetIDStrings.insert(nextID, at: 0)
                    counter += 1
                    store.fetcher.swifter.getTweet(for: nextID, success: sh, failure: failureHandler)
                    
                    
                } else {
                    finalReloadView()
                }
            }
            //先加入ID再获取Status
            session.tweetIDStrings.insert(initialTweetIDString, at: 0)
            getStatus(id: initialTweetIDString)
            
        }
//        store.dispatch(.clearSessionData)
        getReplyDetail(for: initialTweetIDString)
        
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
