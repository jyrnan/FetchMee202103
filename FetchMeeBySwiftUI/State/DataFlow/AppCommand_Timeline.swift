//
//  AppCommand_Timeline.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/24.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Swifter

struct FetchTimelineCommand: AppCommand {
    
    enum UpdateMode {
        case top
        case bottom
    }
    
    var timeline: AppState.TimelineData.Timeline
    
    var timelineType: TimelineType
    var updateMode: UpdateMode
    
    func execute(in store: Store) {
        let swifter = store.swifter
        
        var sinceIDString: String? {updateMode == .top ? timeline.tweetIDStrings.first : nil }
        var maxIDString: String? {updateMode == .bottom ? timeline.tweetIDStrings.last : nil}
        
        let count: Int = 40
        
        func successHandeler(json: JSON) -> Void {
            var timelineWillUpdate = timeline
            
            guard let newTweets = json.array else {return}
            timelineWillUpdate.newTweetNumber += newTweets.count
            
            newTweets.forEach{ addDataToStore($0) }
            
            switch updateMode {
            case .top:
                timelineWillUpdate.tweetIDStrings = updateTimelineTop(tweetIDStrings: timeline.tweetIDStrings, with: newTweets)
            case .bottom:
                timelineWillUpdate.tweetIDStrings = updateTimelineBottom(tweetIDStrings: timeline.tweetIDStrings, with: newTweets)
            }
            
            store.dipatch(.fetchTimelineDone(timeline: timelineWillUpdate))
        }
        
        func failureHandler(_ error: Error) -> Void {
            store.dipatch(.alertOn(text: error.localizedDescription, isWarning: true))
        }
        
        
        switch timeline.type {
        case .home:
            swifter.getHomeTimeline(count: count, sinceID: sinceIDString, maxID: maxIDString, success: successHandeler, failure: failureHandler)
        case .mention:
        swifter.getMentionsTimelineTweets(count: count, sinceID: sinceIDString, maxID: maxIDString, success: successHandeler, failure: failureHandler)
            
        case .favorite:
            swifter.getRecentlyFavoritedTweets(count: count, sinceID: sinceIDString, maxID: maxIDString, success: successHandeler, failure: failureHandler)
            
        case .list( let id, _):
            let listTag = ListTag.id(id)
            swifter.listTweets(for: listTag, sinceID: sinceIDString, maxID: maxIDString, count: count, includeEntities: nil, includeRTs: nil, tweetMode: .default, success: successHandeler, failure: failureHandler)
            
        default: print("")
        
        }
    }
    
    
    
}

extension FetchTimelineCommand {
    
    func updateTimelineTop(tweetIDStrings: [String], with newTweets: [JSON]) -> [String] {
        var tweetIDStrings = tweetIDStrings
        
        guard !newTweets.isEmpty else {return tweetIDStrings}
        let newTweetIDStrings = converJSON2TweetIDStrings(from: newTweets)

        tweetIDStrings = newTweetIDStrings + tweetIDStrings
//        setSinceAndMaxID()
        return tweetIDStrings
    }
    
    func updateTimelineBottom(tweetIDStrings: [String], with newTweets: [JSON]) -> [String] {
        var tweetIDStrings = tweetIDStrings
        
        guard !newTweets.isEmpty else {return tweetIDStrings}
        let newTweetIDStrings = converJSON2TweetIDStrings(from: newTweets)
        
        tweetIDStrings = tweetIDStrings.dropLast() + newTweetIDStrings //需要丢掉原来最后一条推文，否则会重复
//        setSinceAndMaxID()
        return tweetIDStrings
    }
    
    /// 产生推文ID的序列
    /// - Parameter newTweets: 获取的推文数据
    /// - Returns: 提取的推文ID序列
    func converJSON2TweetIDStrings(from newTweets: [JSON]) -> [String] {
        return newTweets.map{$0["id_str"].string!}
    }
    
    ///把推文数据添加到Repository里面，
    func addDataToStore(_ data: JSON) {
        StatusRepository.shared.addStatus(data)
        UserRepository.shared.addUser(data["user"])
        ///添加mention到mention用户信息中
//        addMentionToCount(mention: data)
    }
}


//MARK:-
