//
//  ToolsViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/4.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import UIKit
import Swifter

class ToolsViewModel: ObservableObject {
    var status: JSON
    
    @Published var retweeted: Bool
    @Published var retweetedCount: Int
    
    @Published var favorited: Bool
    @Published var favoritedCount: Int
    
    
    var tweetIDString: String {status["id_str"].string ?? "0000"}
    
    init(status: JSON) {
        self.status = status
        self.retweeted = status["retweeted"].bool ?? false
        self.retweetedCount = status["retweet_count"].integer ?? 0
        self.favorited = status["favorited"].bool ?? false
        self.favoritedCount = status["favorite_count"].integer ?? 0
    }
    
    func retweet() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        switch retweeted {
            case true:
                swifter.unretweetTweet(forID: tweetIDString)
                self.retweeted = false
                retweetedCount -= 1
            case false:
                swifter.retweetTweet(forID: tweetIDString)
                self.retweeted = true
                retweetedCount += 1
        }
    }
    
    func favorite() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        switch favorited {
        case true:
            swifter.unfavoriteTweet(forID: tweetIDString)
            favorited = false
            favoritedCount -= 1
        case false:
            swifter.favoriteTweet(forID: tweetIDString)
            favorited = true
            favoritedCount += 1
        }
    }
    
    
}
