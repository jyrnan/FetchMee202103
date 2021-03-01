//
//  AppState.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/23.
//  Copyright © 2021 jyrnan. All rights reserved.
//


import Combine
import Swifter
import SwiftUI

struct AppState {
    var setting = Setting()
    var timelineData = TimelineData()
}

extension AppState {
    
    struct Setting {
        
        struct Alert {
            var isPresentedAlert: Bool = false
            var alertText: String = ""
            var isWarning: Bool = false
        }
        
        var alert = Alert()
        
        var isProcessingDone: Bool = true
        
        var isShowImageViewer: Bool = false //是否浮动显示图片
        var presentedView: AnyView? //通过AnyView就可以实现任意View的传递了？！
        
        ///User及login部分
        @FileStorage(directory: .documentDirectory, fileName: "user.json")
        var loginUser: UserInfo?
        
        var loginRequesting = false
        var loginError: AppError?
        
        var lists: [String: String] = [:] //前面是ID，后面是name
    }
}

extension AppState {
    struct TimelineData {
        struct Timeline {
            var type: TimelineType = .home
            
            var tweetIDStrings: [String] = []
            var newTweetNumber: Int = 0
            
        }
        
        /// 所有timeline的数据
        var timelines: [String: Timeline] = [
            TimelineType.home.rawValue:Timeline(type: .home),
            TimelineType.mention.rawValue: Timeline(type: .mention),
            TimelineType.favorite.rawValue: Timeline(type: .favorite),
            TimelineType.session.rawValue: Timeline(type: .session),
            TimelineType.user(userID: "0000").rawValue: Timeline(type: .user(userID: "0000"))]
        
        /// 选中的推文ID
        var selectedTweetID: String?
        /// 待查看的用户信息
        var requestedUser: UserInfo = UserInfo()
    }
    
}

extension AppState.TimelineData {
    
    /// 用来清理timeline的数据，保持轻量化
    mutating func clearTimelineData() {
        self.timelines.values.filter{$0.tweetIDStrings.count > 20}
            .forEach{timeline in
                var timeline = timeline
                let count = timeline.tweetIDStrings.count
                let keepTweetCount = 20
                timeline.tweetIDStrings.removeLast(count - keepTweetCount)
                self.timelines[timeline.type.rawValue] = timeline
            }
    }
    
    /// 根据传入的推文ID设置相应的数据操作来标记被选择推文
    /// - Parameter tweetIDString: 要选择推文的ID
    /// - Returns: 根据选择推文的不同情况来输出一个可能需要的后续处理的命令。
    mutating func setSelectedRowIndex(tweetIDString: String) -> AppCommand? {
        
        if self.selectedTweetID != nil {
            //如果选中推文的值本来就有有数值， 那首先清空timeline里面的toolViewMark标记
            clearToolsViewMark()
            
            if self.selectedTweetID == tweetIDString {
                //如果等于传入的tweetID，则直接设置成空
                self.selectedTweetID = nil
                return nil
            } else {
                //如果不等于传入的tweetID，则先设置成nil，再通过一个延迟设置选择推文的命令来延迟设置成新的ID
                self.selectedTweetID = nil
                return DelayedSeletcTweetRowCommand(tweetIDString: tweetIDString)
            }
            
        } else {
            //如果选中推文的值本来是空， 就直接赋值
            self.selectedTweetID = tweetIDString
            setToolsViewMark(after: tweetIDString)
            return nil
        }
    }
    
    mutating func clearToolsViewMark() {
        let timelines = self.timelines.filter{$1.tweetIDStrings.contains("toolsViewMark")}
        if let key = timelines.keys.first,
           var timeline = timelines.values.first {
            
            if let index = (timeline.tweetIDStrings.firstIndex(of:  "toolsViewMark")) {
                timeline.tweetIDStrings.remove(at: index) }
            
            self.timelines[key] = timeline }
    }
    
    mutating func setToolsViewMark(after tweetIDString: String) {
        let timelines = self.timelines.filter{$1.tweetIDStrings.contains(tweetIDString)}
        let key = timelines.keys.first
        var timeline = timelines.values.first
        
        if let index = (timeline?.tweetIDStrings.firstIndex(of: tweetIDString)) {
            timeline?.tweetIDStrings.insert("toolsViewMark", at: index + 1)
            
            self.timelines[key!] = timeline}
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
}

