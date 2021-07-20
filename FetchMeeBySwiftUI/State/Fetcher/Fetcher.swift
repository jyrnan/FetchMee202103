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
    typealias MentionUserData = [User.MentionUser]
    typealias TweetIDStrings = [String]
}

/// 基于Swifter的API中间件
struct FetcherSwifter: Fetcher {
    unowned var store: Store?
    
    var swifter = Swifter(consumerKey: "wa43gWPPaNLYiZCdvZLXlA",
                          consumerSecret: "BvKyqaWgze9BP3adOSTtsX6PnBOG5ubOwJmGpwh8w")
    var count: Int = 90
    var loginUserID: String? {store?.appState.setting.loginUser?.id}
    
    var adapter = Adapter()
    
    /// 用来设置登录后服务提供者新的状态
    mutating func setLogined() {
        if let tokenKey = store?.appState.setting.loginUser?.tokenKey,
           let tokenSecret = store?.appState.setting.loginUser?.tokenSecret {
            swifter = Swifter(consumerKey: "wa43gWPPaNLYiZCdvZLXlA",
                              consumerSecret: "BvKyqaWgze9BP3adOSTtsX6PnBOG5ubOwJmGpwh8w",
                              oauthToken: tokenKey,
                              oauthTokenSecret: tokenSecret)
        }
    }
    
    //TODO: 需要调整将数据存储到repository的频率
    /// 在推文基本操作的Publisher基础上，生成一个基于刷新模式的Publisher，
    /// - 提示： 这个Pulisher可以作为业务模块的调用
    /// - Parameters:
    ///   - updateMode: 更新的模式，例如最新推文（上端更新），或以前就推文（下端更新），
    ///   - timeline: 从Store数据中传入的timeline数据
    ///   - mentionUserData: 从Store数据中传入的mentionUserData数据
    ///   - tweetTags: 从Store数据中传入的TweetTags数据
    /// - Returns: 一个包含更新timeline， 交互用户排序信息和推文标签数据的Publisher
    func makeSessionUpdatePublisher(updateMode: FetchTimelineCommand.UpdateMode,
                                    timeline: Timeline,
                                    mentionUserData: MentionUserData) -> AnyPublisher<(Timeline, MentionUserData), AppError> {
        
        /// 将JSON格式的数据转换成Timeline数据
        /// 并且提取回复用户数据和Tag数据保存
        /// - Parameter json: JSON格式数据
        /// - Returns: 返回Timeline和Mention用户数据打包作为Publisher的数据
        func JSONHandler(json: JSON) -> (Timeline,MentionUserData)  {
            var timelineWillUpdate = timeline
            var mentionUserData: [User.MentionUser] = mentionUserData
            
            guard let newTweets = json.array else {return (timelineWillUpdate, mentionUserData)}
            //只有更新“较新”推文的时候，才有必要更新新推文数量
            if updateMode == .top { timelineWillUpdate.newTweetNumber += newTweets.count}
            
            timelineWillUpdate.updateTweetIDStrings(updateMode: updateMode,
                                                    with: convertJSONToTweetIDStrings(from: newTweets))
            
            newTweets.forEach{
                addDataToRepository($0)
                saveTweetTagToCoreData(status: $0)
                saveStatusToCoreDataIfPostbyUser($0)
                
                guard timeline.type == .mention else {return}
                UserCD.updateOrSaveToCoreData(from: $0["user"])
                storeMentionUserData(mention: $0, to: &mentionUserData)
            }
                
            return (timelineWillUpdate, mentionUserData)
            
        }
        
        func errorHandler(error: Error) -> AppError {
            return AppError.networkingFailed(error)}
        
        return makeSessionOperatePublisher(updateMode: updateMode, timeline: timeline)
            .map(JSONHandler(json:))
            .mapError(errorHandler(error:))
            .eraseToAnyPublisher()
    }
    
    //MARK:- 单条推文数据处理部分
    //包括生产tweetIDStrings，添加推文数据到Repository，生产Tag，MentionUserData
    
    /// 产生推文ID的序列
    /// - Parameter newTweets: 获取的推文数据
    /// - Returns: 提取的推文ID序列
    func convertJSONToTweetIDStrings(from newTweets: [JSON]) -> TweetIDStrings {
        return newTweets.map{$0["id_str"].string!}
    }
    
    
    ///把推文数据添加到Repository里面，
    func addDataToRepository(_ data: JSON) {
//        let status = store?.repository.addStatus(data: data)
        
        let _ = addStatus(data: data)
        
        
        //如果推文是回复login用户的，则需要把该推文用户设置成isFavoriteUser
        if data["in_reply_to_user_id_str"].string == loginUserID {
            let _ = addUser(data: data["user"], isFavoriteUser: true)
        } else {
            let _ = addUser(data: data["user"])}
        
        if data["quoted_status_id_str"].string != nil{
            addDataToRepository(data["quoted_status"])
        }
        
        if data["retweeted_status"]["id_str"].string != nil {
            let retweeted_status = data["retweeted_status"]
            addDataToRepository(retweeted_status)
            ///如果retweet推文内含有引用推文，则把该推文也保存
            if retweeted_status["quoted_status_id_str"].string != nil {
                addDataToRepository(retweeted_status["quoted_status"])
            }
        }
    }
    
    func addStatus(data: JSON) -> Status {
        if let id = data["id_str"].string {
            let status = adapter.convertToStatus(from: data)
            store?.appState.timelineData.statuses[id] = status
            return status
        }
        return Status()
    }
    
    /// 将获取的用户数据保存到CoreData中，并在保存完成后，转换成user格式
    /// - Parameters:
    ///   - data: 传入的用户数据
    ///   - isLoginUser: 标记是否是登陆用户
    ///   - token: 登陆用户的token信息
    /// - Returns: User格式的用户
    func addUser(data: JSON,
                 isLoginUser: Bool? = nil,
                 token: (String?, String?)? = nil,
                 isFavoriteUser: Bool? = nil) -> User {
        guard let id = data["id_str"].string else {return User()}
        //TODO：更新最新的用户follow和推文数量信息
        //利用数据来更新userCD
        let userCD = UserCD.updateOrSaveToCoreData(from: data,
                                                   dataHandler: adapter.updateUserCD(_:with:),
                                                   isLoginUser: isLoginUser,
                                                   token: token,
                                                   isFavoriteUser: isFavoriteUser)
        let user = userCD.convertToUser()
        store?.appState.timelineData.users[id] = user
        return user
        
    }
    
    
    /// 收集Mention用户信息，包括用户ID和mention的ID
    /// - Parameter mention: Mention的data
    func storeMentionUserData(mention:JSON, to mentionUserData: inout [User.MentionUser]) {
        guard let userIDString = mention["user"]["id_str"].string else {return}
        let mentionIDString = mention["id_str"].string!
        let avatarUrlString = mention["user"]["profile_image_url_https"].string!
        
        if let index = mentionUserData.firstIndex(where: {$0.id == userIDString}) {
            mentionUserData[index].mentionsIDs.insert(mentionIDString)
            
        } else {
            let mentionUser = User.MentionUser(id: userIDString,
                                               avatarUrlString: avatarUrlString,
                                               mentionsIDs: Set<String>(arrayLiteral: mentionIDString))
            mentionUserData.append(mentionUser)
        }
    }
    
    
    /// 保存推文中的tag到coredata
    /// - Parameter status: 推文JSON数据
    func saveTweetTagToCoreData(status:JSON) {
        guard let tags = status["entities"]["hashtags"].array, !tags.isEmpty else {return }
        let priority = status["user"]["id_str"].string == loginUserID ? 1 : 0
        let _ = tags.forEach{tagJSON in
            if let text = tagJSON["text"].string {
                TweetTagCD.saveTag(text: text, priority: priority)
            }
        }
    }
    
    /// 检测如果是自己发送的原创推文，则保存到本地
    /// - Parameter status: 推文JSON数据
    func saveStatusToCoreDataIfPostbyUser(_ status: JSON) {
        if status["user"]["id_str"].string == loginUserID,
           status["in_reply_to_user_id_str"].string == nil {
            let _ = StatusCD.JSON_Save(from: status) }
    }
}

extension FetcherSwifter {
    //MARK:- Publisher生成
    func makeSessionOperatePublisher(updateMode: FetchTimelineCommand.UpdateMode, timeline: Timeline) -> Future<JSON, Error> {
        var sinceIDString: String? {
            //因为需要保存最近一条Mention推文信息，所以对于更新mention时候，sinceID会读取保存的值
            //TODO:这个保存的id可以进一步拓展到其他session，例如favorite，但是Home其实没有必要
            if timeline.type == .mention, updateMode == .top {
                return store?.appState.timelineData.latestMentionID
            } else {
                return updateMode == .top ? timeline.tweetIDStrings.first : nil
            }
        }
        var maxIDString: String? {updateMode == .bottom ? timeline.tweetIDStrings.last : nil}
        
        switch timeline.type {
        case .home:
            return Future<JSON, Error> {promise in
                swifter.getHomeTimeline(count: count,
                                        sinceID: sinceIDString,
                                        maxID: maxIDString,
                                        success:{promise(.success($0))
                                        },
                                        failure:{promise(.failure($0))
                                        })}
        case .mention:
            return Future<JSON, Error> {promise in
                swifter.getMentionsTimelineTweets(count: count,
                                                  sinceID: sinceIDString,
                                                  maxID: maxIDString,
                                                  success:{promise(.success($0))
                                                  },
                                                  failure:{promise(.failure($0))
                                                  })}
            
        case .favorite:
            return Future<JSON, Error> {promise in
                swifter.getRecentlyFavoritedTweets(count: count,
                                                   sinceID: sinceIDString,
                                                   maxID: maxIDString,
                                                   success:{promise(.success($0))
                                                   },
                                                   failure:{promise(.failure($0))
                                                   })}
            
        case .user(let userID):
            let userTag = UserTag.id(userID)
            return Future<JSON, Error> {promise in
                swifter.getTimeline(for: userTag,
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
                swifter.listTweets(for: listTag,
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
        case .fetchTweet(let ID):
            return Future<JSON, Error> {promise in
                swifter.lookupTweets(for: [ID],
                                     success: {promise(.success($0))},
                                     failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
            
        case .favorite(let ID):
            return Future<JSON, Error> {promise in
                swifter.favoriteTweet(forID: ID,
                                      success: {promise(.success($0))},
                                      failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        case .unfavorite(let ID):
            return Future<JSON, Error> {promise in
                swifter.unfavoriteTweet(forID: ID,
                                        success: {promise(.success($0))},
                                        failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
            
            
        case .retweet(let ID):
            return Future<JSON, Error> {promise in
                swifter.retweetTweet(forID: ID,
                                     ///由于Retweet返回的是一个新推文，并把原推文嵌入在里面，所以返回嵌入推文用了更新界面
                                     success: {promise(.success($0["retweeted_status"]))},
                                     failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        case .unRetweet(let ID):
            return Future<JSON, Error> {promise in
                swifter.unretweetTweet(forID: ID,
                                       success: {
                                        ///由于unRetweet返回的是该推文原来的数据，所以不会导致界面更新
                                        ///因此需要在此基础上增加一个再次获取该推文的操作，并返回更新后的推文数据
                                        let tweetIDString = $0["id_str"].string!
                                        swifter.getTweet(for: tweetIDString, success: {promise(.success($0))})
                                       },
                                       failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
            
        case .quote(let ID):
            return Future<JSON, Error> {promise in
                swifter.unfavoriteTweet(forID: ID,
                                        success: {promise(.success($0))},
                                        failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        case .delete(let ID):
            return Future<JSON, Error> {promise in
                swifter.destroyTweet(forID: ID,
                                     success: {promise(.success($0))},
                                     failure: {promise(.failure($0))})}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}
