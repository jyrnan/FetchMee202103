//
//  TweetRowViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/28.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation

class TweetRowViewModel: ObservableObject{
    //MARK:- Properties
    @Published var tweetMedia: TweetMedia
    var isToolsViewShowed: Bool {timeline.tweetIDStringOfRowToolsViewShowed == tweetIDString}
    
    let timeline: Timeline
    let tweetIDString: String
    
    var retweetMarkView: RetweetMarkView?
    var avatarView: AvatarView!
    var userNameView: UserNameView!
    var replyUsersView: ReplyUsersView?
    var images: Images?
    var playButtonView: PlayButtonView?
    
    
    
    //MARK:- Methods
    init(timeline:Timeline, tweetIDString: String) {
        self.timeline = timeline
        self.tweetIDString = tweetIDString
        
        self.tweetMedia = timeline.tweetMedias[tweetIDString] ?? TweetMedia(id: tweetIDString)
        
        makeViews()
        
        print(#line, #function, "TweetRowViewModel inited")
    }
    
    deinit {
        print(#line, #function, "TweetRowViewModel deinited")
    }
    
    func makeViews() {
        retweetMarkView = makeRetweetMarkView()
        avatarView = makeAvatarView()
        makeUserNameView()
        replyUsersView = makeReplyUsersView()
        makeImagesView()
        makePlayButtonView()
    }
    
    func toggleToolsView() {
        if self.isToolsViewShowed {
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
        userInfo.id = tweetMedia.userIDString!
        userInfo.avatarUrlString = tweetMedia.avatarUrlString
        avatarViewModel = AvatarViewModel(userInfo: userInfo )
        return avatarViewModel
    }
    
    func makeAvatarView() -> AvatarView {
        let avatarViewModel: AvatarViewModel = makeAvatarViewModel()
        return AvatarView(avatarViewModel: avatarViewModel)
    }
    
    func makeUserNameView() {
        if let userName = tweetMedia.userName, let screenName = tweetMedia.screenName {
            userNameView = UserNameView(userName: userName, screenName: screenName)
        }
    }
    
    func makeReplyUsersView() -> ReplyUsersView? {
        guard !tweetMedia.replyUsers.isEmpty else {return nil}
        let replyUsersView = ReplyUsersView(replyUsers: tweetMedia.replyUsers)
        return replyUsersView
    }
    
    func makeImagesView() {
        if let imageUrls = tweetMedia.urlStrings, !imageUrls.isEmpty{
            images = Images(imageUrlStrings: imageUrls)
        }
    }
    
    func makePlayButtonView() {
        let viewModel:PlayButtonViewModel = makePlayButtonViewModel()
        if tweetMedia.mediaType == "video" || tweetMedia.mediaType == "animated_gif" {
            playButtonView = PlayButtonView(viewModel: viewModel)
        }
    }
    
    func makePlayButtonViewModel() -> PlayButtonViewModel {
        return PlayButtonViewModel(url: tweetMedia.mediaUrlString)
    }
}
