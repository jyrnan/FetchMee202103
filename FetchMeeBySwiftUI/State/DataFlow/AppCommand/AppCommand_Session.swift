//
//  AppCommand_Session.swift
//  AppCommand_Session
//
//  Created by jyrnan on 2021/7/22.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Swifter
import SwiftUI

//MARK: - FetchSessionCommand

struct FetchSessionCommand: AppCommand {
    var initialTweetIDString: String
    
    func execute(in store: Store) {
        var session = AppState.TimelineData.Timeline(type: .session)
        var tempStatuses: [String: Status] = [:]
        var tempUsers: [String: User] = [:]
        
        
        func getReplyDetail(for idString: String ) {
            let failureHandler: (Error) -> Void = { error in
                print(#line, error.localizedDescription)}
            
            var counter: Int = 0
            
            func finalReloadView() {
                store.dispatch(.fetchSessionDone(timeline: session, statuses: tempStatuses, users: tempUsers))
            }
            
            func getStatus(id: String) {
                
                //如果status能直接从repository获取，则直接获取
                if let status = store.appState.timelineData.statuses[id] {
                
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
                let data:JSON = json
                
                store.fetcher.addDataToRepository(data, to: &tempStatuses, and: &tempUsers)
                
                if let nextID = data["in_reply_to_status_id_str"].string, counter < 8 {
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
        getReplyDetail(for: initialTweetIDString)
        
    }
    
}
