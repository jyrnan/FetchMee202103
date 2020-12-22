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
    var tweetIDStringOfRowToolsViewShowed: String? //显示ToolsView的推文ID
    
    ///存储根据MentiUserinfo情况排序的UserIDString
    var mentionUserData: [String:[String]] = [:]
    
    var tweetRowViewModels: [String: TweetRowViewModel] = [:] {
        didSet {
            print(#line, "tweetRowModel count", tweetRowViewModels.count)
        }
    }
    
    var toolsViewModel: ToolsViewModel!
    
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
        if let mentionUser = userDefault.object(forKey: "mentionUserData") as? [String:[String]], type == .mention {
            self.mentionUserData = mentionUser //读取数据
            self.saveMentionUserData()//初始化更新MentionUser排序
        }
        
        if tweetIDStrings.isEmpty && type != .list {refreshFromTop(count: 50)}
        
        print(#line, #function,#file, "timeline \(self.type) inited.")
    }
    
    //MARK: - 更新推文函数
    ///更新上方推文
    func refreshFromTop(for userIDString: String? = nil, count: Int = 100, completeHandeler:(() -> Void)? = nil ,fh: ((Error) -> Void)? = nil) {
        self.isDone = false
        
        func successHandeler(json: JSON) ->Void {
            guard let newTweets = json.array else {return}
            self.newTweetNumber += newTweets.count
            
            newTweets.forEach{ addDataToStore($0) }
            
            self.updateTimelineTop(with: newTweets)
            self.isDone = true
            self.saveMentionUserData() //存储MentionUserInfo并更新MentionUser的排序
            
            //用于设置后台刷新完成时调用setTaskCompleted(success: true)
            guard completeHandeler != nil else { return }
            completeHandeler!()
        }
        
        let failureHandler: ((Error) -> Void)? = fh
        
        switch self.type {
        case .mention:
            swifter.getMentionsTimelineTweets(count: count, sinceID: sinceIDString, success: successHandeler, failure: failureHandler)
        case .home:
            swifter.getHomeTimeline(count: count, sinceID: sinceIDString,  success: successHandeler, failure: failureHandler)
        case .user:
            swifter.getTimeline(for: UserTag.id(userIDString ?? "0000"), success: successHandeler, failure: failureHandler)
        case .favorite:
            swifter.getRecentlyFavoritedTweets(count: count, sinceID: sinceIDString, success: successHandeler, failure: failureHandler)
        case .list:
            if let listTag = listTag {
                swifter.listTweets(for: listTag, sinceID: sinceIDString, maxID: maxIDString, count: count, includeEntities: nil, includeRTs: nil, tweetMode: .default, success: successHandeler, failure: failureHandler)
            }
        default: print(#line, #function)
        }
    }
    
    ///从推文下方开始更新
    func refreshFromBottom(for userIDString: String? = nil, count: Int = 20) {
        
        self.isDone = false
        
        func successHandeler(json: JSON) ->Void {
            guard let newTweets = json.array else {return}
            
            newTweets.forEach{ addDataToStore($0) }
            
            updateTimelineBottom(with: newTweets)
            isDone = true
            saveMentionUserData() //存储MentionUserInfo并更新MentionUser的排序
        }
        
        let failureHandler: (Error) -> Void = { error in print(#line, error.localizedDescription)}
        
        switch self.type {
        case .mention:
            isDone = false
            swifter.getMentionsTimelineTweets(count: count, maxID: maxIDString, success: successHandeler, failure: failureHandler)
        case .home:
            isDone = false
            swifter.getHomeTimeline(maxID: maxIDString,  success: successHandeler, failure: failureHandler)
        case .user:
            swifter.getTimeline(for: UserTag.id(userIDString ?? "0000"), count: count, maxID: maxIDString, success: successHandeler, failure: failureHandler)
        case .favorite:
            swifter.getRecentlyFavoritedTweets(count: count, maxID: maxIDString, success: successHandeler, failure: failureHandler)
        case .list:
            if let listTag = listTag {
                swifter.listTweets(for: listTag, maxID: maxIDString, count: count, includeEntities: nil, includeRTs: nil, tweetMode: .default, success: successHandeler, failure: failureHandler)
            }
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
        let avatarUrlString = mention["user"]["profile_image_url_https"].string!
        if self.mentionUserData[userIDString] == nil {
            ///把avatar地址加入到数组的第一个，供后续读取来获取avatar image
            self.mentionUserData[userIDString] = [avatarUrlString, mentionIDString]
        } else {
            ///如果该用户存在，且该推文是该用户新回复，则将推文ID添加至尾端
            if self.mentionUserData[userIDString]?.contains(mentionIDString ) == false {
                self.mentionUserData[userIDString]?.append(mentionIDString)
            }
        }
    }
    
    ///保存mention用户信息到persistent store
    func saveMentionUserData() {
        guard self.type == .mention else {return}
        ///先保存当前的回复用户信息。
        userDefault.set(self.mentionUserData, forKey: "mentionUserData") 
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
        var tweetIDString = tweetIDString
        if tweetIDString.contains("toolsView") {
            tweetIDString = String(tweetIDString.dropLast(9))
            
            let tweetRowViewModel = TweetRowViewModel(timeline: self, tweetIDString: tweetIDString, width: width, isToolsViewOnly:true)
            return tweetRowViewModel
        }
        
        
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
    
  
    
    func toggleToolsView(tweetIDString : String) {
        
        toolsViewModel = ToolsViewModel(timeline: self, tweetIDString: tweetIDString)
        
        guard let index = tweetIDStrings.firstIndex(of: tweetIDString) else { return }
        
        switch tweetIDStringOfRowToolsViewShowed {
        case nil:
            tweetIDStringOfRowToolsViewShowed = tweetIDString
            withAnimation {tweetIDStrings.insert(tweetIDString + "toolsView", at: index + 1)}
        case tweetIDString:
            tweetIDStringOfRowToolsViewShowed = nil
            let _ = withAnimation {tweetIDStrings.remove(at: index + 1)}
        default:
            ///先删除，再添加，避免冲突。
            ///在删除
            
            
            guard let indexOfRemove  = tweetIDStrings.firstIndex(of: tweetIDStringOfRowToolsViewShowed!) else { return }
            let _ = withAnimation() {self.tweetIDStrings.remove(at: indexOfRemove + 1)}
            tweetIDStringOfRowToolsViewShowed = nil
            
            ///删除后延迟再次运行，实际就是在下一轮运行中添加
            delay(delay: 0.5, closure: { self.toggleToolsView(tweetIDString: tweetIDString)})

        }
    }
    
    func removeToolsView() {
        guard let index = tweetIDStrings.firstIndex(where: {$0.contains("toolsView")}) else {return}
        let _ =  withAnimation{tweetIDStrings.remove(at: index)}
        tweetIDStringOfRowToolsViewShowed = nil
    }
}

extension Timeline {
    
    
    /// 如果推文属于timeline后端，则往下刷新推文。
    /// - Parameter tweetIDString: 执行此操作的推文ID
    func fetchMoreIfNeeded(tweetIDString: String) {
        ///需要往下刷新推文的推文位置，是从后倒数
        let shouldFetchIndex = 5
        guard tweetIDStrings.count > shouldFetchIndex else {return}
        let index = tweetIDStrings.count - shouldFetchIndex
        if tweetIDStrings[index] == tweetIDString {
            refreshFromBottom(count: 50)
        }
    }
    
    
    /// 如果超过一定数量的推文，则移除后面超出数目
    func reduceTweetsIfNeed() {
        let shoulKeepNumber: Int = 50
        guard tweetIDStrings.count > shoulKeepNumber else { return }
        print(#line, "Remove \(tweetIDStrings.count - shoulKeepNumber) tweets")
        tweetIDStrings.removeLast(tweetIDStrings.count - shoulKeepNumber)
        maxIDString = tweetIDStrings.last
       
    }
    
    func removeTweetRowModelIfNeed() {
        tweetRowViewModels.removeAll()
        print(tweetRowViewModels)
    }
}
