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

    var timeline: TimelineViewModel
    var tweetIDString: String {status["id_str"].string ?? "0000"}
    //传人的视窗宽度
    var width: CGFloat
    
    var retweetMarkView: RetweetMarkView?
    var avatarView: AvatarView!
    var userNameView: UserNameView!
    var detailIndicator: DetailIndicator!
    var images: Images?
    var playButtonView: PlayButtonView?
    var quotedTweetRow: QuotedTweetRow?
    var toolsVeiw: ToolsView? {makeToolsView()}
    var statusTextView: NSAttributedStringView?
    
    var isReplyToMe: Bool!
    
   

    //MARK:- Methods
    init(timeline:TimelineViewModel, tweetIDString: String, width: CGFloat) {
        self.timeline = timeline
        self.width = width
        ///MVVM
        self.status = StatusRepository.shared.status[tweetIDString] ?? JSON.init("")
        
        ///备用
        self.tweetMedia = (timeline as? Timeline)?.tweetMedias[tweetIDString] ?? TweetMedia(id: tweetIDString)
        makeViews()
    }
    
    func makeViews() {
        retweetMarkView = makeRetweetMarkView()
        avatarView = makeAvatarView()
        userNameView = makeUserNameView()
        detailIndicator = makeDetailIndicatorView()
        statusTextView = makeStatusTextView()
        images = makeImagesView()
        playButtonView = makePlayButtonView()
        quotedTweetRow = makeQuotedTweetRowView()
        isReplyToMe = checkIsReplyToMe()
    }
    
    
    func makeRetweetMarkView() -> RetweetMarkView? {
        guard status["retweeted_status"]["id_str"].string != nil else {return nil }
        let id = status["user"]["id_str"].string
        let name = status["user"]["name"].string
        
        let retweetMarkView = RetweetMarkView(userIDString: id, userName: name)
        
        self.status = status["retweeted_status"]
        StatusRepository.shared.addStatus(status)
        
        UserRepository.shared.addUser(status["user"])
        
        return retweetMarkView
    }
    
    //MARK:-AvatarView
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
    
    func makeDetailIndicatorView() -> DetailIndicator {
        return DetailIndicator(tweetIDString: tweetIDString)
    }
    
    func makeStatusTextView() -> NSAttributedStringView?{
        guard status["text"].string != nil else {return nil}
        let viewModel = StatusTextViewModel(status: status)
        return NSAttributedStringView(viewModel: viewModel, width: width - 80)
    }
    
    
    func makeImagesView() -> Images? {
        guard let medias = status["extended_entities"]["media"].array else {return nil}
        let imageUrls = medias.map{$0["media_url_https"].string!}
        let images = Images(imageUrlStrings: imageUrls)
        return images
    }
    
    //MARK:-playButton
    func makePlayButtonViewModel() -> PlayButtonViewModel {
        let videoUrl = status["extended_entities"]["media"].array?.first?["video_info"]["variants"].array?.first?["url"].string
        return PlayButtonViewModel(url: videoUrl)
    }
    
    func makePlayButtonView() -> PlayButtonView? {
        guard let medias = status["extended_entities"]["media"].array else {return nil}
        guard medias.first?["type"] == "video" || medias.first?["type"] == "animated_gif" else {return nil}
        let viewModel:PlayButtonViewModel = makePlayButtonViewModel()
        let playButtonView = PlayButtonView(viewModel: viewModel)
        return playButtonView
    }
    
    
    //MARK:-QuotedTweetRowView
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
    
    //MARK:-ToolsView
    func makeToolsViewModel() -> ToolsViewModel {
        return ToolsViewModel(status: status, timeline: timeline)
    }
    
    func makeToolsView() -> ToolsView? {
        guard timeline.tweetIDStringOfRowToolsViewShowed == tweetIDString else {return nil}
        let viewModel = makeToolsViewModel()
        return ToolsView(viewModel: viewModel)
    }
    
    func toggleToolsView() {
        if timeline.tweetIDStringOfRowToolsViewShowed == tweetIDString {
            ///判断如果先前选定显示ToolsView的tweetID不是自己，
            ///则将原激活ToolSView的推文取消激活
            timeline.tweetIDStringOfRowToolsViewShowed = nil
        } else {
            timeline.tweetIDStringOfRowToolsViewShowed = tweetIDString }
    }
    
    
    func checkIsReplyToMe() -> Bool {
        return userDefault.object(forKey: "userIDString") as? String == status["in_reply_to_user_id_str"].string
    }
}
