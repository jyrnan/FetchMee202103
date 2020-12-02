//
//  TweetRowViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/28.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import Swifter

class TweetRowViewModel: ObservableObject{
    //MARK:- Properties
    var tweetMedia: TweetMedia
    
    ///MVVM
    var status: JSON

    let timeline: Timeline
    let tweetIDString: String
    
    var retweetMarkView: RetweetMarkView?
    var avatarView: AvatarView!
    var userNameView: UserNameView!
    var replyUsersView: ReplyUsersView?
    var images: Images?
    var playButtonView: PlayButtonView?
    var quotedTweetRow: QuotedTweetRow?
    var toolsVeiw: ToolsView? {makeToolsView()}
    
    var isReplyToMe: Bool!
    
    var userName:String {status["user"]["name"].string ?? "UnkownName"}
    var screenName:String {status["user"]["screen_name"].string ?? "UnkownName"}
  
    //MARK:- Methods
    init(timeline:Timeline, tweetIDString: String) {
        self.timeline = timeline
        self.tweetIDString = tweetIDString
        
        self.tweetMedia = timeline.tweetMedias[tweetIDString] ?? TweetMedia(id: tweetIDString)
        
        ///MVVM
        self.status = StatusRepository.shared.status[tweetIDString] ?? JSON.init("")
        
        makeViews()
    }
    
    func makeViews() {
        retweetMarkView = makeRetweetMarkView()
        avatarView = makeAvatarView()
        userNameView = makeUserNameView()
        replyUsersView = makeReplyUsersView()
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
        guard let name = tweetMedia.retweeted_by_UserName, let id = tweetMedia.retweeted_by_IDString  else {return nil }
        let retweetMarkView = RetweetMarkView(userIDString: id, userName: name)
        return retweetMarkView
    }
    
    //生产AvatarView头像
    
    func makeAvatarViewModel() -> AvatarViewModel {
        var avatarViewModel: AvatarViewModel
        var userInfo = UserInfo()
        userInfo.id = tweetMedia.userIDString ?? "0000"
        userInfo.avatarUrlString = tweetMedia.avatarUrlString
        
        ///MVVM
        let user = status["user"]
        
        avatarViewModel = AvatarViewModel(userInfo: userInfo, user: user )
        return avatarViewModel
    }
    
    func makeAvatarView() -> AvatarView {
        let avatarViewModel: AvatarViewModel = makeAvatarViewModel()
        return AvatarView(avatarViewModel: avatarViewModel)
    }
    
    func makeUserNameView() -> UserNameView {
//        let userName = tweetMedia.userName ?? "UserName"
//        let screenName = tweetMedia.screenName ?? "ScreenName"
        let userNameView = UserNameView(userName: userName, screenName: screenName)
        return userNameView
    }
    
    func makeReplyUsersView() -> ReplyUsersView? {
        guard !tweetMedia.replyUsers.isEmpty else {return nil}
        let replyUsersView = ReplyUsersView(replyUsers: tweetMedia.replyUsers)
        return replyUsersView
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
        
        return TweetRowViewModel(timeline: timeline, tweetIDString: quotedTweetIDString)
    }
    
    func makeQuotedTweetRowView() -> QuotedTweetRow? {
        guard status["quoted_status_id_str"].string != nil else {return nil}
        
       
        let quotedTweetRowViewModel = makeQuotedTweetRowViewModel()
        let quotedTweetRow = QuotedTweetRow(viewModel: quotedTweetRowViewModel)
        return quotedTweetRow
    }
    
    func makeToolsView() -> ToolsView? {
        guard timeline.tweetIDStringOfRowToolsViewShowed == tweetIDString else {return nil}
        return ToolsView(timeline: timeline, tweetIDString: tweetIDString)
    }
    
    func checkIsReplyToMe() -> Bool {
        return userDefault.object(forKey: "userIDString") as? String == tweetMedia.in_reply_to_user_id_str && timeline.type == .home
    }
}
