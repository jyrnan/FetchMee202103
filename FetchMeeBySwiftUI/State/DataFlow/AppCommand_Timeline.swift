//
//  AppCommand_Timeline.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/24.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Swifter
import SwiftUI

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
            var mentionUserData: [String : [String]]? = store.appState.setting.loginUser?.mentionUserData ?? [:]
            
            guard let newTweets = json.array else {return}
            timelineWillUpdate.newTweetNumber += newTweets.count
            
            newTweets.forEach{
                addDataToRepository($0)
                guard self.timelineType == .mention else {return}
                addMentionToCount(mention: $0, to: &mentionUserData)
            }
            
            
            switch updateMode {
            case .top:
                timelineWillUpdate.tweetIDStrings = updateTimelineTop(tweetIDStrings: timeline.tweetIDStrings, with: newTweets)
            case .bottom:
                timelineWillUpdate.tweetIDStrings = updateTimelineBottom(tweetIDStrings: timeline.tweetIDStrings, with: newTweets)
            }
            
            store.dipatch(.fetchTimelineDone(timeline: timelineWillUpdate, mentionUserData: mentionUserData))
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
            
        case .user(let userID) :
            let userTag = UserTag.id(userID)
            swifter.getTimeline(for: userTag, count: count, sinceID: sinceIDString, maxID: maxIDString, success: successHandeler, failure: failureHandler)
            
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
    func addDataToRepository(_ data: JSON) {
        StatusRepository.shared.addStatus(data)
        UserRepository.shared.addUser(data["user"])
        ///添加mention到mention用户信息中
//        addMentionToCount(mention: data)
    }
    
    /// 收集Mention用户信息，包括用户ID和mention的ID
    /// - Parameter mention: Mention的data
    func addMentionToCount(mention:JSON, to mentionUserData: inout [String:[String]]?) {
        guard let userIDString = mention["user"]["id_str"].string else {return}
        let mentionIDString = mention["id_str"].string!
        let avatarUrlString = mention["user"]["profile_image_url_https"].string!
        if mentionUserData?[userIDString] == nil {
            
            ///把avatar地址加入到数组的第一个，供后续读取来获取avatar image
            mentionUserData?[userIDString] = [avatarUrlString, mentionIDString]
        } else {
            ///如果该用户存在，且该推文是该用户新回复，则将推文ID添加至尾端
            if mentionUserData?[userIDString]?.contains(mentionIDString ) == false {
                mentionUserData?[userIDString]?.append(mentionIDString)
            }
        }
        print(#line, #function, mentionUserData)

    }
}


//MARK:- FetchSessionCommand

struct FetchSessionCommand: AppCommand {
    var initialTweetIDString: String
    
    func execute(in store: Store) {
        var session = AppState.TimelineData.Timeline(type: .session)
        
        func getReplyDetail(for idString: String ) {
            let failureHandler: (Error) -> Void = { error in
                print(#line, error.localizedDescription)}
            
            var counter: Int = 0
            
            func finalReloadView() {
                store.dipatch(.fetchSessionDone(timeline: session))
            }
            func sh(json: JSON) -> () {
                let status:JSON = json
                guard let newTweetIDString = status["id_str"].string else {return}
                
                StatusRepository.shared.addStatus(status)
                UserRepository.shared.addUser(status["user"])
            
                session.tweetIDStrings.insert(newTweetIDString, at: 0)
                if let in_reply_to_status_id_str = status["in_reply_to_status_id_str"].string, counter < 8 {
                    ///如果推文已经下过在推文仓库可以获取，则直接获取，否则从网络获取
                    if let status = StatusRepository.shared.status[in_reply_to_status_id_str] {
                        sh(json: status)
                    } else {
                        store.swifter.getTweet(for: in_reply_to_status_id_str, success: sh, failure: failureHandler)
                    }
                    counter += 1
                } else {
                    finalReloadView()
                }
            }
            
            let status = StatusRepository.shared.status[initialTweetIDString]! //必定是有这个status返回的
            sh(json: status)
        }
        
        getReplyDetail(for: initialTweetIDString)
        
    }
    
}

/// 延时选择推文的执行命令
struct DelayedSeletcTweetRowCommand: AppCommand {
    let tweetIDString: String
    func execute(in store: Store) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation{
            store.dipatch(.selectTweetRow(tweetIDString: tweetIDString))
            }
        }
    }
}

/// 设置要通过Toast来在最前面展示的View
struct ClearPresentedView: AppCommand {
    func execute(in store: Store) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            store.appState.setting.presentedView = nil
        }
    }
}
