//
//  AppState+TimelineData.swift
//  FetchMee
//
//  Created by jyrnan on 2021/4/30.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

extension AppState {
    struct TimelineData {
        typealias HubStatus = (myLatestStatus:StatusCD?, bookmarkedStatus: StatusCD?, myLatestDraft:TweetDraft?)
        
        struct Timeline {
            var type: TimelineType = .home
            var newTweetNumber: Int = 0
            var tweetIDStrings: [String] = []
            var status: [Status] = []
        }
        
        /// 所有timeline的数据
        var timelines: [String: Timeline] = ["Home": Timeline(type: .home),
                                             "Mention": Timeline(type: .mention),
                                             "Favorite": Timeline(type: .favorite)]
        
        var statuses: [String: Status] = [:]
        var users: [String: User] = [:]
        
        ///persistant最新回复推文的id
        @FileStorage(directory: .documentDirectory, fileName: "latestMentionID.json")
        var latestMentionID: String?

        var mentionUserData: [User.MentionUser] = []
        ///首页hubView推文信息
        var hubStatus:HubStatus = (nil, nil, nil)
        
    }
}

extension AppState.TimelineData {
    
    func getStatus(byID id: String) -> Status {
        if let status = self.statuses[id] {
            return status
        }
        return Status()
    }
    
    func getUser(byID id: String) -> User {
        if let user = self.users[id] {
            return user
        }
        
//        if let userCD = bookMarkedUserCD.filter({$0.userIDString == id}).first {
//            let user = userCD.convertToUser()
//            users[id] = user
//            return user
//        }
        
        return User()
    }
    
    /// 用来清理timeline的数据，保持轻量化
    mutating func clearTimelineData() {
        let keepTweetCount = 150
        
        self.timelines
            .filter{$0.value.tweetIDStrings.count > keepTweetCount}
            .forEach{self.timelines[$0]?.tweetIDStrings.removeLast($1.tweetIDStrings.count - keepTweetCount)}
        
        //获取所有的tweetID集合用于后续判断
        //TODO: 需要增加保留推文中的引用，retweet推文的ID
        let tweetIDStrings = Set(timelines.values.flatMap{$0.tweetIDStrings})
        print(#line, #function, tweetIDStrings)
    }
    
    mutating func initialSessionData(with status: Status) {
        guard timelines[TimelineType.session.rawValue] != nil else {return}
        timelines[TimelineType.session.rawValue]?.tweetIDStrings.removeAll()
        timelines[TimelineType.session.rawValue]?.tweetIDStrings.append(status.id)
        timelines[TimelineType.session.rawValue]?.status.removeAll()
        timelines[TimelineType.session.rawValue]?.status.append(status)
    }
   
    
    /// 针对所有的timeline清除某推文id
    mutating func deleteFromTimelines(of id: String) {
        self.timelines
            .filter{$1.tweetIDStrings.contains(id)}
            .forEach{
                let index = $1.tweetIDStrings.firstIndex(of:  id)!
                self.timelines[$0]?.tweetIDStrings.remove(at: index) }}
    
    ///更新所有timeline里面的某个status
    mutating func updateStatus(with stauts: Status) {
        self.statuses[stauts.id] = stauts
    }
    
    /// 更新相应timeline的新推文数
    /// - Parameters:
    ///   - timelineType: timeline的类型，用来定位具体是哪一条timeline
    ///   - numberOfReadTweet: timelineView在浏览时候生成的已阅读推文的数量
    mutating func updateNewTweetNumber(timelineType: TimelineType, numberOfReadTweet: Int) {
        if let newTweetNumber = self.timelines[timelineType.rawValue]?.newTweetNumber,
           newTweetNumber - numberOfReadTweet > 0 {
            self.timelines[timelineType.rawValue]?.newTweetNumber = (newTweetNumber - numberOfReadTweet)
        } else {
            self.timelines[timelineType.rawValue]?.newTweetNumber = 0
        }
    }
    
    func getTimeline(timelineType: TimelineType) -> AppState.TimelineData.Timeline {
        let key = timelineType.rawValue
        guard let timeline = self.timelines[key] else {
            return AppState.TimelineData.Timeline(type: timelineType)
        }
        return timeline
    }
}

extension AppState.TimelineData.Timeline {
    mutating func updateTweetIDStrings(updateMode: FetchTimelineCommand.UpdateMode, with newIDStrings: [String]) {
        switch updateMode {
        case .top:
            self.tweetIDStrings = newIDStrings + self.tweetIDStrings
        case .bottom:
            if self.tweetIDStrings.last == newIDStrings.first {
                self.tweetIDStrings = self.tweetIDStrings.dropLast() + newIDStrings
            } else {
                self.tweetIDStrings = self.tweetIDStrings + newIDStrings
            }
        }
    }
}
