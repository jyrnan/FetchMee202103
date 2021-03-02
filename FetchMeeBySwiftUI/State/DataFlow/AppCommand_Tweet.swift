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
        
        var publisher: AnyPublisher<JSON, Error> {
            switch operation {
            case .favorite:
                return Future<JSON, Error> {promise in
                    store.swifter.favoriteTweet(forID: tweetIDString,
                                                success: {promise(.success($0))},
                                                failure: {promise(.failure($0))})}.eraseToAnyPublisher()
            case .unfavorite:
                return Future<JSON, Error> {promise in
                    store.swifter.unfavoriteTweet(forID: tweetIDString,
                                                success: {promise(.success($0))},
                                                failure: {promise(.failure($0))})}.eraseToAnyPublisher()
            default:
                return Future<JSON, Error> {promise in
                    promise(.success(JSON.init("")))
                }.eraseToAnyPublisher()
            }
            
            func TweetOperationPublisher(tweetIDString: String, operation: TweetCommand.Operation) -> AnyPublisher<JSON, Error> {
                switch operation {
                case .favorite:
                    print("")
                default:
                    print("")
                }
            }
        }
        
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        publisher
        .sink(receiveCompletion: {
                switch $0 {
        case .failure(let error):
            store.dipatch(.alertOn(text: error.localizedDescription, isWarning: true))
        case .finished:
            print("Nothing")
        }
            token.unseal()
        },
              receiveValue: {
                StatusRepository.shared.addStatus($0)
                store.dipatch(.update)
              })
        .seal(in: token)
        
    }
}

extension TweetCommand {
    
}
