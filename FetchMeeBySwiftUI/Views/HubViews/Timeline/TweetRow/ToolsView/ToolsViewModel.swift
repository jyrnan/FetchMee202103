//
//  ToolsViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/4.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import UIKit
import Swifter
import Combine

class ToolsViewModel: ObservableObject {
    var status: JSON
//    var timeline: TimelineViewModel
    var tweetIDString: String
    
    @Published var retweeted: Bool
    @Published var retweetedCount: Int
    
    @Published var favorited: Bool
    @Published var favoritedCount: Int
    
    init(tweetIDString: String) {
        self.status = StatusRepository.shared.status[tweetIDString] ?? JSON.init("")
        self.tweetIDString = tweetIDString
        
        self.retweeted = status["retweeted"].bool ?? false
        self.retweetedCount = status["retweet_count"].integer ?? 0
        self.favorited = status["favorited"].bool ?? false
        self.favoritedCount = status["favorite_count"].integer ?? 0
    }
    
    deinit {
    }
    
    func retweet() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        switch retweeted {
            case true:
                swifter.unretweetTweet(forID: tweetIDString, success: {json in
                    let status = json
                    self.status = json
                    StatusRepository.shared.addStatus(status)
                    self.retweeted = false
                    self.retweetedCount -= 1
                })
//
            case false:
                swifter.retweetTweet(forID: tweetIDString, success: {json in
                    let status = json
                    StatusRepository.shared.addStatus(status)
                    self.retweeted = true
                    self.retweetedCount += 1
                })
        }
    }
    
    func favorite() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        switch favorited {
        case true:
            swifter.unfavoriteTweet(forID: tweetIDString, success: {json in
                StatusRepository.shared.addStatus(json)
                self.favorited = false
                self.favoritedCount -= 1
            })
            
        case false:
            swifter.favoriteTweet(forID: tweetIDString, success: {json in
                StatusRepository.shared.addStatus(json)
                self.favorited = true
                self.favoritedCount += 1
            })
            
        }
    }
    
    
}
