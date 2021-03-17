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
        
        FetcherSwifter.provider = store.swifter
        let fecher = FetcherSwifter(repository: store.repository)
                
        fecher.makeTweetOperatePublisher(operation: operation)
            .sink(receiveCompletion: {complete in
                    if case .failure(let error) = complete {
                        store.dipatch(.alertOn(text: error.localizedDescription, isWarning: true))
                    }
                    token.unseal()},
                  receiveValue: {
                    
                    fecher.repository.addStatus(data: $0)
                    store.dipatch(.update)
                  })
            .seal(in: token)
    }
}
