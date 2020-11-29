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
    var images: Images?
    var playButtonView: PlayButtonView?
    
    //MARK:- Methods
    init(timeline:Timeline, tweetIDString: String) {
        self.timeline = timeline
        self.tweetIDString = tweetIDString
        
        self.tweetMedia = timeline.tweetMedias[tweetIDString] ?? TweetMedia(id: tweetIDString)
        
        makeViews()
    }
    
    func makeViews() {
        checkIsRetweet()
        makeAvatarView()
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
    
    func checkIsRetweet() {
        if let name = tweetMedia.retweeted_by_UserName, let id = tweetMedia.retweeted_by_IDString {
            makeRetweetMarkView(id: id, name: name)
        }
    }
    
    func makeRetweetMarkView(id: String, name: String) {
        self.retweetMarkView = RetweetMarkView(userIDString: id, userName: name)
    }
    
    func makeAvatarView() {
        if let userID = tweetMedia.userIDString, let avatarUrl = tweetMedia.avatarUrlString {
            var userInfo = UserInfo()
            userInfo.id = userID
            userInfo.avatarUrlString = avatarUrl
            self.avatarView = AvatarView(userInfo: userInfo )
        }
        
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
        return PlayButtonViewModel(timeline: timeline,
                                   url: tweetMedia.mediaUrlString)
    }
    
}
