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
    var timeline: TimelineViewModel
    
    @Published var retweeted: Bool
    var retweetedCount: Int {status["retweet_count"].integer ?? 0}
    
    var favorited: Bool {status["favorited"].bool ?? false}
    var favoritedCount: Int {status["favorite_count"].integer ?? 0}
    
    
    var tweetIDString: String
    
    init(timeline: TimelineViewModel, tweetIDString: String) {
        self.status = StatusRepository.shared.status[tweetIDString] ?? JSON.init("")
         self.timeline = timeline
        self.tweetIDString = tweetIDString
        
        self.retweeted = status["retweeted"].bool ?? false
//        self.retweetedCount = status["retweet_count"].integer ?? 0
//        self.favorited = status["favorited"].bool ?? false
//        self.favoritedCount = status["favorite_count"].integer ?? 0
        print(#line, #file, "inited.")
    }
    
    deinit {
        print(#line, #file, "deinited.")
    }
    
    func retweet() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        switch retweeted {
            case true:
                swifter.unretweetTweet(forID: tweetIDString, success: {json in
                    let status = json
                    self.status = json
                    StatusRepository.shared.addStatus(status)
                    print(#line,#file, "unretweeted")
                    self.retweeted = false
                    //                retweetedCount -= 1
                })
//
            case false:
                swifter.retweetTweet(forID: tweetIDString, success: {json in
                    let status = json
                    StatusRepository.shared.addStatus(status)
                    print(#line,#file, "retweeted")
                    self.retweeted = true
                })
//                self.retweeted = true
//                retweetedCount += 1
        }
    }
    
    func favorite() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        switch favorited {
        case true:
            swifter.unfavoriteTweet(forID: tweetIDString, success: {json in
                StatusRepository.shared.addStatus(json)
            })
//            favorited = false
//            favoritedCount -= 1
        case false:
            swifter.favoriteTweet(forID: tweetIDString, success: {json in
                StatusRepository.shared.addStatus(json)
            })
//            favorited = true
//            favoritedCount += 1
        }
    }
    
    
}
