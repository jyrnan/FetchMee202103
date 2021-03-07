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
    
    
    enum Operation {
        case favorite
        case unfavorite
        case retweet
        case unRetweet
        case quote
        case delete
    }
    
    var operation: Operation
    var tweetIDString: String
    
    func execute(in store: Store) {
        let token = SubscriptionToken()
                
        store.swifter.operatePublisher(operation: operation, targetID: tweetIDString)
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

extension Swifter {
    
    func operatePublisher(operation: TweetCommand.Operation, targetID: String) ->AnyPublisher<JSON, Error> {
        switch operation {
        case .favorite:
            return Future<JSON, Error> {promise in
                self.favoriteTweet(forID: targetID,
                                   success: {promise(.success($0))},
                                   failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        case .unfavorite:
            return Future<JSON, Error> {promise in
                self.unfavoriteTweet(forID: targetID,
                                     success: {promise(.success($0))},
                                     failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        
            
        case .retweet:
            return Future<JSON, Error> {promise in
                self.retweetTweet(forID: targetID,
                                  ///由于Retweet返回的是一个新推文，并把原推文嵌入在里面，所以返回嵌入推文用了更新界面
                                  success: {promise(.success($0["retweeted_status"]))},
                                  failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        case .unRetweet:
            return Future<JSON, Error> {promise in
                self.unretweetTweet(forID: targetID,
                                    success: {
                                        ///由于unRetweet返回的是该推文原来的数据，所以不会导致界面更新
                                        ///因此需要在此基础上增加一个再次获取该推文的操作，并返回更新后的推文数据
                                        let tweetIDString = $0["id_str"].string!
                                        self.getTweet(for: tweetIDString, success: {promise(.success($0))})
                                        },
                                    failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
            
        case .quote:
            return Future<JSON, Error> {promise in
                self.unfavoriteTweet(forID: targetID,
                                     success: {promise(.success($0))},
                                     failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        case .delete:
            return Future<JSON, Error> {promise in
                self.destroyTweet(forID: targetID,
                                  success: {promise(.success($0))},
                                  failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}


struct SaveTagCommand: AppCommand {
    func execute(in store: Store) {
        let tags = store.appState.setting.tweetTags
        
        tags?.forEach{
            TweetTagCD.saveTag(text: $0.text, priority: $0.priority, to: store.context)
        }
    }
    
    
}
