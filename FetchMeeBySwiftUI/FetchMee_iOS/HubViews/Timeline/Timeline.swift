//
//  Timeline.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//


import SwiftUI
import Swifter
import Photos

final class Timeline: TimelineViewModel, ObservableObject {
    
    //MARK:-Properties
    @Published var tweetIDStrings: [String] = []
    @Published var newTweetNumber: Int = 0
    @Published var isDone: Bool = true { //设定在更新任务时候状态指示器是否显示，但无论任务是否结束，10秒种后状态指示器消失
        didSet {
            delay(delay: 10, closure: {
                if self.isDone  == false {
                    self.isDone = true
                }
            })
        }
    }
    @Published var tweetIDStringOfRowToolsViewShowed: String? //显示ToolsView的推文ID
    
    ///存储根据MentiUserinfo情况排序的UserIDString
    @Published var mentionUserIDStringsSorted: [String] = []
    var mentionUserInfo: [String:[String]] = [:]
    
    var tweetRowViewModels: [String: TweetRowViewModel] = [:]
    
    var type: TimelineType
    var listTag: ListTag? // 如果是list类型，则会传入listTag
    let maxCounter: Int = 100
    var sinceIDString: String?
    var maxIDString: String?
    
    //MARK:-Methods
    init(type: TimelineType, listTag: ListTag? = nil) {
        self.type = type
        self.listTag = listTag
        ///如果是Mention类型则读取存储好的相应用户数据
        if let mentionUser = userDefault.object(forKey: "mentionUserInfo") as? [String:[String]], type == .mention {
            self.mentionUserInfo = mentionUser //读取数据
            self.makeMentionUserSortedList()//初始化更新MentionUser排序
        }
        
        if tweetIDStrings.isEmpty {refreshFromTop()}
        
        print(#line, #function,#file, "timeline \(self.type) inited.")
    }
    
    //MARK: - 更新推文函数
    ///更新上方推文
    func refreshFromTop(for userIDString: String? = nil, completeHandeler:(() -> Void)? = nil ,fh: ((Error) -> Void)? = nil) {
        
        func successHandeler(json: JSON) ->Void {
            guard let newTweets = json.array else {return}
//            self.newTweetNumber += newTweets.count
            
            newTweets.forEach{ addDataToStore($0) }
            
            self.updateTimelineTop(with: newTweets)
            self.isDone = true
            self.makeMentionUserSortedList() //存储MentionUserInfo并更新MentionUser的排序
            
            //用于设置后台刷新完成时调用setTaskCompleted(success: true)
            guard completeHandeler != nil else { return }
            completeHandeler!()
        }
        
        let failureHandler: ((Error) -> Void)? = fh
        
        switch self.type {
        case .mention:
            swifter.getMentionsTimelineTweets(count: maxCounter, sinceID: sinceIDString, success: successHandeler, failure: failureHandler)
        case .home:
            swifter.getHomeTimeline(count: maxCounter, sinceID: sinceIDString,  success: successHandeler, failure: failureHandler)
        case .user:
            swifter.getTimeline(for: UserTag.id(userIDString ?? "0000"), success: successHandeler, failure: failureHandler)
        case .favorite:
            swifter.getRecentlyFavoritedTweets(success: successHandeler, failure: failureHandler)
        case .list:
            if let listTag = listTag {
                swifter.listTweets(for: listTag, sinceID: sinceIDString, maxID: maxIDString, count: maxCounter, includeEntities: nil, includeRTs: nil, tweetMode: .default, success: successHandeler, failure: failureHandler)
            }
        default: print(#line, #function)
        }
    }
    
    ///从推文下方开始更新
    func refreshFromBottom(for userIDString: String? = nil) {
        func successHandeler(json: JSON) ->Void {
            guard let newTweets = json.array else {return}
            
            newTweets.forEach{ addDataToStore($0) }
            
            updateTimelineBottom(with: newTweets)
            isDone = true
            makeMentionUserSortedList() //存储MentionUserInfo并更新MentionUser的排序
        }
        
        let failureHandler: (Error) -> Void = { error in print(#line, error.localizedDescription)}
        
        switch self.type {
        case .mention:
            isDone = false
            swifter.getMentionsTimelineTweets(count: maxCounter, maxID: maxIDString, success: successHandeler, failure: failureHandler)
        case .home:
            isDone = false
            swifter.getHomeTimeline(count: maxCounter,maxID: maxIDString,  success: successHandeler, failure: failureHandler)
        case .user:
            swifter.getTimeline(for: UserTag.id(userIDString ?? "0000"), count: maxCounter, maxID: maxIDString, success: successHandeler, failure: failureHandler)
        case .favorite:
            swifter.getRecentlyFavoritedTweets(count: maxCounter, maxID: maxIDString, success: successHandeler, failure: failureHandler)
        default:print(#line, #function)
        }
    }
    
    func updateTimelineTop(with newTweets: [JSON]) {
        guard !newTweets.isEmpty else {return}
        let newTweetIDStrings = converJSON2TweetIDStrings(from: newTweets)
        self.sinceIDString = newTweetIDStrings.first //获取新推文的第一条，作为下次刷新的起始点
        if self.tweetIDStrings.isEmpty {
            self.maxIDString = newTweetIDStrings.last //如果是全新刷新，则需要设置maxIDstring，以保证今后刷新下部推文会从当前最后一条开始。
        }
        
        self.tweetIDStrings = newTweetIDStrings + self.tweetIDStrings
    }
    
    func updateTimelineBottom(with newTweets: [JSON]) {
        guard !newTweets.isEmpty else {return}
        let newTweetIDStrings = converJSON2TweetIDStrings(from: newTweets)
        self.maxIDString = newTweetIDStrings.last //获取新推文的最后一条，作为下次刷新的起始点
        
        self.tweetIDStrings = self.tweetIDStrings.dropLast() + newTweetIDStrings //需要丢掉原来最后一条推文，否则会重复
    }
    
    func converJSON2TweetIDStrings(from newTweets: [JSON]) -> [String] {
        return newTweets.map{$0["id_str"].string!}
    }
    
    func addDataToStore(_ data: JSON) {
        StatusRepository.shared.addStatus(data)
        UserRepository.shared.addUser(data["user"])
        addMentionToCount(mention: data)
    }
}

extension Timeline {
    /// 收集Mention用户信息，包括用户ID和mention的ID
    /// - Parameter mention: Mention的data
    func addMentionToCount(mention:JSON) {
        guard self.type == .mention else {return}
        guard let userIDString = mention["user"]["id_str"].string else {return}
        let mentionIDString = mention["id_str"].string!
        if self.mentionUserInfo[userIDString] == nil {
            self.mentionUserInfo[userIDString] = [mentionIDString]
        } else {
            ///如果该用户存在，且该推文是该用户新回复，则将推文ID添加至尾端
            if self.mentionUserInfo[userIDString]?.contains(mentionIDString ) == false {
                self.mentionUserInfo[userIDString]?.append(mentionIDString)
            }
        }
    }
    
    ///生成互动用户的排序列表并存储用户回复的用户和推文ID列表
    func makeMentionUserSortedList() {
        guard self.type == .mention else {return}
        ///先保存当前的回复用户信息。
        userDefault.set(self.mentionUserInfo, forKey: "mentionUserInfo")
        ///按Mention数量照降序排序再生产排序的userIDString
        let mentionUserInfoSorted = self.mentionUserInfo.sorted{$0.value.count > $1.value.count}
        self.mentionUserIDStringsSorted = mentionUserInfoSorted.map{$0.key}
    }
}

extension Timeline {
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

extension Timeline {
    func getTweetViewModel(tweetIDString: String, width: CGFloat) -> TweetRowViewModel {
        if let tweetRowViewModel = tweetRowViewModels[tweetIDString] {
            return tweetRowViewModel
        } else {
            return makeTweetRowViewModel(tweetIDString: tweetIDString, width: width)
        }
    }
    
    func makeTweetRowViewModel(tweetIDString: String, width: CGFloat) ->TweetRowViewModel {
        let tweetRowViewModel = TweetRowViewModel(timeline: self, tweetIDString: tweetIDString, width: width)
        tweetRowViewModels[tweetIDString] = tweetRowViewModel
        return tweetRowViewModel
    }
}
