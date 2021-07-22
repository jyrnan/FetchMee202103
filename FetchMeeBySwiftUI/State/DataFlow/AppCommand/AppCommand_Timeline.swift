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
    var mentionUserData: [User.MentionUser]
    var statuses: [String: Status] = [:]
    var users: [String: User] = [:]
    
    func execute(in store: Store) {
        let token = SubscriptionToken()
        
        store.fetcher.makeSessionUpdatePublisher(updateMode: updateMode, timeline: timeline, mentionUserData: mentionUserData, statuses: statuses, users: users)
            .sink(receiveCompletion: {complete in
                if case .failure(let error) = complete {
                    store.dispatch(.alertOn(text: error.localizedDescription, isWarning: true))
                }
                token.unseal()
            },
            receiveValue: {
                store.dispatch(.fetchTimelineDone(timeline: $0.0, mentionUserData: $0.1, statuses: $0.2, users: $0.3))
            })
            .seal(in: token)
    }
}
