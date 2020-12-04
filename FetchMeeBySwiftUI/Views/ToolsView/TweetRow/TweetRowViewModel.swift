//
//  TweetRowViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/28.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import UIKit
import Swifter

class TweetRowViewModel: ObservableObject{
    //MARK:- Properties
    var tweetMedia: TweetMedia
    
    ///MVVM
    var status: JSON

    let timeline: Timeline
   
    //传人的视窗宽度
    var width: CGFloat
    
    var retweetMarkView: RetweetMarkView?
    var avatarView: AvatarView!
    var userNameView: UserNameView!
//    var replyUsersView: ReplyUsersView!
    var images: Images?
    var playButtonView: PlayButtonView?
    var quotedTweetRow: QuotedTweetRow?
    var toolsVeiw: ToolsView? {makeToolsView()}
    
    var statusTextView: NSAttributedStringView?
    
    var isReplyToMe: Bool!
    
    var tweetIDString: String {status["id_str"].string ?? "0000"}
//    var userName:String {status["user"]["name"].string ?? "name"}
//    var screenName:String {status["user"]["screen_name"].string ?? "screenName"}
    
    
  
    //MARK:- Methods
    init(timeline:Timeline, tweetIDString: String, width: CGFloat) {
        self.timeline = timeline
        self.width = width
        ///MVVM
        self.status = StatusRepository.shared.status[tweetIDString] ?? JSON.init("")
        
        ///备用
        self.tweetMedia = timeline.tweetMedias[tweetIDString] ?? TweetMedia(id: tweetIDString)
        makeViews()
    }
    
    func makeViews() {
        retweetMarkView = makeRetweetMarkView()
        avatarView = makeAvatarView()
        userNameView = makeUserNameView()
//        replyUsersView = makeReplyUsersView()
        statusTextView = makeStatusTextView()
        images = makeImagesView()
        playButtonView = makePlayButtonView()
        quotedTweetRow = makeQuotedTweetRowView()
        isReplyToMe = checkIsReplyToMe()
       
    }
    
    func toggleToolsView() {
        if timeline.tweetIDStringOfRowToolsViewShowed == tweetIDString {
            ///判断如果先前选定显示ToolsView的tweetID不是自己，
            ///则将原激活ToolSView的推文取消激活
            timeline.tweetIDStringOfRowToolsViewShowed = nil
        } else {
            timeline.tweetIDStringOfRowToolsViewShowed = tweetIDString }
    }
    
    func makeRetweetMarkView() -> RetweetMarkView? {
        guard status["retweeted_status"]["id_str"].string != nil else {return nil }
        let id = status["user"]["id_str"].string
        let name = status["user"]["name"].string
        
        let retweetMarkView = RetweetMarkView(userIDString: id, userName: name)
        
        self.status = status["retweeted_status"]
        StatusRepository.shared.addStatus(status)
        
        return retweetMarkView
    }
    
    //生产AvatarView头像
    
    func makeAvatarViewModel() -> AvatarViewModel {
        var avatarViewModel: AvatarViewModel
        
        ///MVVM
        let user = status["user"]
        
        avatarViewModel = AvatarViewModel(user: user )
        return avatarViewModel
    }
    
    func makeAvatarView() -> AvatarView {
        let avatarViewModel: AvatarViewModel = makeAvatarViewModel()
        return AvatarView(viewModel: avatarViewModel)
    }
    
    func makeUserNameView() -> UserNameView {
        let userName = status["user"]["name"].string ?? "name"
        let screenName = status["user"]["screen_name"].string ?? "screenName"
        let userNameView = UserNameView(userName: userName, screenName: screenName)
        return userNameView
    }
    
    func makeStatusTextView() -> NSAttributedStringView?{
        guard status["text"].string != nil else {return nil}
        let viewModel = StatusTextViewModel(status: status)
        return NSAttributedStringView(viewModel: viewModel, width: width - 80)
    }
    
   
    
    func makeImagesView() -> Images? {
        guard let imageUrls = tweetMedia.urlStrings, !imageUrls.isEmpty else {return nil}
        let images = Images(imageUrlStrings: imageUrls)
        return images
    }
    
    func makePlayButtonView() -> PlayButtonView? {
        guard tweetMedia.mediaType == "video" || tweetMedia.mediaType == "animated_gif" else {return nil}
        let viewModel:PlayButtonViewModel = makePlayButtonViewModel()
        let playButtonView = PlayButtonView(viewModel: viewModel)
        return playButtonView
    }
    
    func makePlayButtonViewModel() -> PlayButtonViewModel {
        return PlayButtonViewModel(url: tweetMedia.mediaUrlString)
    }
    
    func makeQuotedTweetRowViewModel() -> TweetRowViewModel {
        
        let quotedTweetIDString = status["quoted_status_id_str"].string ?? "0000"
        let quotedStatus = status["quoted_status"]
        
        StatusRepository.shared.status[quotedTweetIDString] = quotedStatus
        
        return TweetRowViewModel(timeline: timeline, tweetIDString: quotedTweetIDString, width: width - 90)
    }
    
    func makeQuotedTweetRowView() -> QuotedTweetRow? {
        guard status["quoted_status_id_str"].string != nil else {return nil}
        
       
        let quotedTweetRowViewModel = makeQuotedTweetRowViewModel()
        let quotedTweetRow = QuotedTweetRow(viewModel: quotedTweetRowViewModel)
        return quotedTweetRow
    }
    
    func makeToolsViewModel() -> ToolsViewModel {
        return ToolsViewModel(status: status, timeline: timeline)
    }
    
    func makeToolsView() -> ToolsView? {
        guard timeline.tweetIDStringOfRowToolsViewShowed == tweetIDString else {return nil}
        let viewModel = makeToolsViewModel()
        return ToolsView(viewModel: viewModel)
    }
    
    func checkIsReplyToMe() -> Bool {
        return userDefault.object(forKey: "userIDString") as? String == tweetMedia.in_reply_to_user_id_str && timeline.type == .home
    }
    
    
    
    ///ReplyUserView
    ///TODO: 需要按照JSON信息来提取
//    func makeReplyUserViewModel() ->ReplyUserViewModel {
//        return ReplyUserViewModel(status: status)
//    }
//
//    func makeReplyUsersView() -> ReplyUsersView {
//        let viewModel = makeReplyUserViewModel()
//        let replyUsersView = ReplyUsersView(viewModel: viewModel)
//        return replyUsersView
//    }
}
