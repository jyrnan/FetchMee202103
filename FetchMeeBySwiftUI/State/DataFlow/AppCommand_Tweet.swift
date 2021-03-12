//
//  AppCommand_Tweet.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/2.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Swifter
import Combine
import UIKit

struct TweetCommand: AppCommand {
    
    
    enum TweetOperation {
        case favorite(id: String)
        case unfavorite(id: String)
        case retweet(id: String)
        case unRetweet(id: String)
        case quote(id: String)
        case delete(id: String)
    }
    
    var operation: TweetCommand.TweetOperation
    
    func execute(in store: Store) {
        let token = SubscriptionToken()
        
        FetcherSw.provider = store.swifter
        let fecher = FetcherSw()
                
        fecher.makeTweetOperatePublisher(operation: operation)
            .sink(receiveCompletion: {complete in
                    if case .failure(let error) = complete {
                        store.dipatch(.alertOn(text: error.localizedDescription, isWarning: true))
                    }
                    token.unseal()},
                  receiveValue: {
                    
                    StatusRepository.shared.addStatus($0)
                    store.dipatch(.update)
                  })
            .seal(in: token)
    }
}

/// 用来把推文浏览过程中收集到的tag保存到CoreData中
struct SaveTagToCoreDataCommand: AppCommand {
    func execute(in store: Store) {
        let tags = store.appState.setting.tweetTags
        
        tags.forEach{
            TweetTagCD.saveTag(text: $0.text, priority: $0.priority, to: store.context)
        }
    }
    
    
}
