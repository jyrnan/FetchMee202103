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
    typealias MentionUserData = [UserInfo.MentionUser]
    typealias TweetIDStrings = [String]
    
    //    func updateTimeline(updateMode: UpdateMode, timeline: Timeline ) -> AnyPublisher<Timeline, AppError>
    
}

/// 基于Swifter的API中间件
struct FetcherSw: Fetcher {
    ///每次刷新的推文数量
    var count: Int = 40
    
    static var provider: Swifter!
    
    /// 在推文基本操作的Publisher基础上，生成一个基于刷新模式的Publisher，
    /// - 提示： 这个Pulisher可以作为业务模块的调用
    /// - Parameters:
    ///   - updateMode: 更新的模式，例如最新推文（上端更新），或以前就推文（下端更新），
    ///   - timeline: 从Store数据中传入的timeline数据
    ///   - mentionUserData: 从Store数据中传入的mentionUserData数据
    ///   - tweetTags: 从Store数据中传入的TweetTags数据
    /// - Returns: 一个包含更新timeline， 交互用户排序信息和推文标签数据的Publisher
    func makeSessionUpdataPublisher(updateMode: FetchTimelineCommand.UpdateMode,
                        timeline: Timeline,
                        mentionUserData: MentionUserData) -> AnyPublisher<(Timeline, MentionUserData), AppError> {
        
        /// 将JSON格式的数据转换成Timeline数据
        /// 并且提取回复用户数据和Tag数据保存
        /// - Parameter json: JSON格式数据
        /// - Returns: 返回Timeline和Mention用户数据打包作为Publisher的数据
        func JSONHandler(json: JSON) -> (Timeline,MentionUserData)  {
            var timelineWillUpdate = timeline
            var mentionUserData: [UserInfo.MentionUser] = mentionUserData
            
            guard let newTweets = json.array else {return (timelineWillUpdate, mentionUserData)}
            timelineWillUpdate.newTweetNumber += newTweets.count
            timelineWillUpdate.updateTweetIDStrings(updateMode: updateMode, with: converJSON2TweetIDStrings(from: newTweets))
            
            newTweets.forEach{
                addDataToRepository($0)
                saveTweetTagToCoreData(status: $0)
                guard timeline.type == .mention else {return}
                TwitterUser.updateOrSaveToCoreData(from: $0["user"])
                storeMentionUserData(mention: $0, to: &mentionUserData)
            }
            
            return (timelineWillUpdate, mentionUserData)
                    }
        
        func errorHandler(error: Error) -> AppError {
            return AppError.netwokingFailed(error)}
        
        let publisher = makeSessionOperatePublisher(updateMode: updateMode, timeline: timeline)
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
    func storeMentionUserData(mention:JSON, to mentionUserData: inout [UserInfo.MentionUser]) {
        guard let userIDString = mention["user"]["id_str"].string else {return}
        let mentionIDString = mention["id_str"].string!
        let avatarUrlString = mention["user"]["profile_image_url_https"].string!
        
        if let index = mentionUserData.firstIndex(where: {$0.id == userIDString}) {
            mentionUserData[index].mentionsIDs.insert(mentionIDString)
            
        } else {
            let mentionUser = UserInfo.MentionUser(id: userIDString,
                                                   avatarUrlString: avatarUrlString,
                                                   mentionsIDs: Set<String>(arrayLiteral: mentionIDString))
            mentionUserData.append(mentionUser)
        }
    }
    
    
    /// 保存推文中的tag到coredata
    /// - Parameter status: 推文JSON数据
    func saveTweetTagToCoreData(status:JSON) {
        guard let tags = status["entities"]["hashtags"].array, !tags.isEmpty else {return }
        let _ = tags.forEach{tagJSON in
            if let text = tagJSON["text"].string {
                TweetTagCD.saveTag(text: text, priority: 0)
            }
        }
    }
    
    //MARK:- Publisher生成
    func makeSessionOperatePublisher(updateMode: FetchTimelineCommand.UpdateMode, timeline: Timeline) -> Future<JSON, Error> {
        var sinceIDString: String? {updateMode == .top ? timeline.tweetIDStrings.first : nil }
        var maxIDString: String? {updateMode == .bottom ? timeline.tweetIDStrings.last : nil}
        
        print(#line, #function)
        
        switch timeline.type {
        case .home:
            return Future<JSON, Error> {promise in
                FetcherSw.provider.getHomeTimeline(count: count,
                                                   sinceID: sinceIDString,
                                                   maxID: maxIDString,
                                                   success:{promise(.success($0))
                                                   },
                                                   failure:{promise(.failure($0))
                                                   })}
        case .mention:
            return Future<JSON, Error> {promise in
                FetcherSw.provider.getMentionsTimelineTweets(count: count,
                                                             sinceID: sinceIDString,
                                                             maxID: maxIDString,
                                                             success:{promise(.success($0))
                                                             },
                                                             failure:{promise(.failure($0))
                                                             })}
            
        case .favorite:
            return Future<JSON, Error> {promise in
                FetcherSw.provider.getRecentlyFavoritedTweets(count: count,
                                                              sinceID: sinceIDString,
                                                              maxID: maxIDString,
                                                              success:{promise(.success($0))
                                                              },
                                                              failure:{promise(.failure($0))
                                                              })}
            
        case .user(let userID):
            let userTag = UserTag.id(userID)
            return Future<JSON, Error> {promise in
                FetcherSw.provider.getTimeline(for: userTag,
                                               count: count,
                                               sinceID: sinceIDString,
                                               maxID: maxIDString,
                                               success:{promise(.success($0))
                                               },
                                               failure:{promise(.failure($0))
                                               })}
            
        case .list( let id, _):
            let listTag = ListTag.id(id)
            return Future<JSON, Error> {promise in
                FetcherSw.provider.listTweets(for: listTag,
                                              sinceID: sinceIDString,
                                              maxID: maxIDString,
                                              count: count,
                                              success:{promise(.success($0))
                                              },
                                              failure:{promise(.failure($0))
                                              })}
            
            
        default:
            return Future<JSON, Error> {promise in
                promise(.success(JSON.init("")))}

        }
    }
    
    func makeTweetOperatePublisher(operation: TweetCommand.TweetOperation) -> AnyPublisher<JSON, Error> {
        
        
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