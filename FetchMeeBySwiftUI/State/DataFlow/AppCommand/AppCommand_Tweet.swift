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
import SwiftUI

struct TweetCommand: AppCommand {
    
    
    enum TweetOperation {
        case fetchTweet(id: String)
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
        var timelineData = store.appState.timelineData
        
        store.fetcher.makeTweetOperatePublisher(operation: operation)
            .sink(receiveCompletion: {complete in
                if case .failure(let error) = complete {
                    store.dispatch(.alertOn(text: error.localizedDescription, isWarning: true))
                }
                token.unseal()},
                  receiveValue: {
                let status = Adapter().convertToStatus(from: $0)
                timelineData.updateStatus(with: status)
                
                if case let .delete(id) = operation {
                    //如果是删除推文的操作，则需要在完成服务器端操作后执行本地推文数据的删除
                    //需要同时删除推文ID和ToolsView
                    timelineData.deleteFromTimelines(of: id)
                }
                withAnimation{
                    store.dispatch(.tweetOperationDone(timelineData: timelineData))
                }
            })
            .seal(in: token)
    }
}
