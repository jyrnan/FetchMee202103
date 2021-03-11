//
//  Fetcher.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/11.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Combine
import Swifter
import CoreData

protocol Fetcher {
    typealias Timeline = AppState.TimelineData.Timeline
    typealias TweetIDStrings = [String]
    
//    func updateTimeline(updateMode: UpdateMode, timeline: Timeline ) -> AnyPublisher<Timeline, AppError>

}
extension Fetcher {
    
}

    enum TweetOperation {
        case favorite(id: String)
        case unfavorite(id: String)
        case retweet(id: String)
        case unRetweet(id: String)
        case quote(id: String)
        case delete(id: String)
    }
    
    enum UpdateMode {
        case top
        case bottom
    }



struct FetcherSw: Fetcher {
    ///每次刷新的推文数量
    var count: Int = 40
    
    static var provider: Swifter!
    
    func updateTimeline(updateMode: UpdateMode,
                        timeline: Timeline,
                        tweetTags: Set<AppState.Setting.TweetTag>?,
                        mentionUserData: [UserInfo.MentionUser]?) -> AnyPublisher<Timeline, AppError> {
        
        func JSONHandler(json: JSON) -> Timeline {
            var timelineWillUpdate = timeline
            var tweetTags:Set<AppState.Setting.TweetTag> = tweetTags ?? []
            var mentionUserData: [UserInfo.MentionUser]? = mentionUserData
            
            guard let newTweets = json.array else {return timelineWillUpdate}
            timelineWillUpdate.newTweetNumber += newTweets.count
            timelineWillUpdate.updateTweetIDStrings(updateMode: updateMode, with: converJSON2TweetIDStrings(from: newTweets))
            
            newTweets.forEach{
                addDataToRepository($0)
                saveTweetTag(status: $0, tweetTags: &tweetTags)
                countMentionUser(mention: $0, to: &mentionUserData)
            }
             
            return timelineWillUpdate
            
        }
        
        func errorHandler(error: Error) -> AppError {
            return AppError.netwokingFailed(error)}
        
        let publisher = sessionOperatePublisher(updateMode: updateMode, timeline: timeline)
            .map(JSONHandler(json:))
            .mapError(errorHandler(error:))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        return publisher
    }
    
    //MARK:- 单条推文数据处理部分
    //包括生产tweetiIDStrings，添加推文数据到Repository，生产Tag，MentionUserData
   
    
    /// 产生推文ID的序列
    /// - Parameter newTweets: 获取的推文数据
    /// - Returns: 提取的推文ID序列
    func converJSON2TweetIDStrings(from newTweets: [JSON]) -> TweetIDStrings {
        return newTweets.map{$0["id_str"].string!}
    }
    
    
    ///把推文数据添加到Repository里面，
    func addDataToRepository(_ data: JSON) {
        StatusRepository.shared.addStatus(data)
        UserRepository.shared.addUser(data["user"])
    }
    
    
    /// 收集Mention用户信息，包括用户ID和mention的ID
    /// - Parameter mention: Mention的data
    func countMentionUser(mention:JSON, to mentionUserData: inout [UserInfo.MentionUser]?) {
        guard let userIDString = mention["user"]["id_str"].string else {return}
        let mentionIDString = mention["id_str"].string!
        let avatarUrlString = mention["user"]["profile_image_url_https"].string!
        
        if let index = mentionUserData?.firstIndex(where: {$0.id == userIDString}) {
            mentionUserData?[index].mentionsIDs.insert(mentionIDString)

        } else {
            let mentionUser = UserInfo.MentionUser(id: userIDString,
                                                   avatarUrlString: avatarUrlString,
                                                   mentionsIDs: Set<String>(arrayLiteral: mentionIDString))
            mentionUserData?.append(mentionUser)
        }
    }
    
    
    /// 保存推文中的tag到coredata
    /// - Parameter status: 推文JSON数据
    func saveTweetTag(status:JSON, tweetTags: inout Set<AppState.Setting.TweetTag>) {
        guard let tags = status["entities"]["hashtags"].array,
              !tags.isEmpty else {return }
        let tweetTagTexts = tweetTags.map{$0.text}
        let _ = tags.forEach{tagJSON in
            if let text = tagJSON["text"].string {
                guard !tweetTagTexts.contains(text) else {return}
           
                let tweetTag = AppState.Setting.TweetTag(priority: 0,
                                                         text: text)
                tweetTags.insert(tweetTag)
                print(#line, #function, tweetTag)
            }
        }
    }
    
    //MARK:- Publisher生成
    func sessionOperatePublisher(updateMode: UpdateMode, timeline: Timeline) -> Future<JSON, Error> {
        var sinceIDString: String? {updateMode == .top ? timeline.tweetIDStrings.first : nil }
        var maxIDString: String? {updateMode == .bottom ? timeline.tweetIDStrings.last : nil}
        
        
        
        switch timeline.type {
        case .home:
            return Future<JSON, Error> {promise in
                FetcherSw.provider.getHomeTimeline(count: count,
                                                 sinceID: sinceIDString,
                                                 maxID: maxIDString,
                                                 success:{promise(.success($0))},
                                                 failure:{promise(.failure($0))})
            }
            
        default:
            return Future<JSON, Error> {promise in
                promise(.success(JSON.init("")))}
                
        }
    }
    
    func tweetOperatePublisher(operation: TweetOperation) -> AnyPublisher<JSON, Error> {
        
        
        switch operation {
        case .favorite(let ID):
            return Future<JSON, Error> {promise in
                FetcherSw.provider.favoriteTweet(forID: ID,
                                   success: {promise(.success($0))},
                                   failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        case .unfavorite(let ID):
            return Future<JSON, Error> {promise in
                FetcherSw.provider.unfavoriteTweet(forID: ID,
                                     success: {promise(.success($0))},
                                     failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        
            
        case .retweet(let ID):
            return Future<JSON, Error> {promise in
                FetcherSw.provider.retweetTweet(forID: ID,
                                  ///由于Retweet返回的是一个新推文，并把原推文嵌入在里面，所以返回嵌入推文用了更新界面
                                  success: {promise(.success($0["retweeted_status"]))},
                                  failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        case .unRetweet(let ID):
            return Future<JSON, Error> {promise in
                FetcherSw.provider.unretweetTweet(forID: ID,
                                    success: {
                                        ///由于unRetweet返回的是该推文原来的数据，所以不会导致界面更新
                                        ///因此需要在此基础上增加一个再次获取该推文的操作，并返回更新后的推文数据
                                        let tweetIDString = $0["id_str"].string!
                                        FetcherSw.provider.getTweet(for: tweetIDString, success: {promise(.success($0))})
                                        },
                                    failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
            
        case .quote(let ID):
            return Future<JSON, Error> {promise in
                FetcherSw.provider.unfavoriteTweet(forID: ID,
                                     success: {promise(.success($0))},
                                     failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        case .delete(let ID):
            return Future<JSON, Error> {promise in
                FetcherSw.provider.destroyTweet(forID: ID,
                                  success: {promise(.success($0))},
                                  failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
    

}
