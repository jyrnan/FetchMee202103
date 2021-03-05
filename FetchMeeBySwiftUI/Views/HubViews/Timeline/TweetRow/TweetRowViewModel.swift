//
//  TweetRowViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/28.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import UIKit
import Swifter
import SwiftUI

class TweetRowViewModel: ObservableObject{
    static var count: Int = 0
    
    //MARK:- Properties
    
    ///MVVM
    var status: JSON

    var tweetIDString: String
    
    //传人的视窗宽度
    var tweetRowViewWidth: CGFloat
    
    ///图标栏宽度
    var iconColumWidth: CGFloat = 48
    
    var retweetMarkView: RetweetMarkView?
    var avatarView: AvatarView!
    var userNameView: UserNameView!
    var detailIndicator: DetailIndicator!
    var images: Images?
    var playButtonView: PlayButtonView?
    var quotedTweetRow: QuotedTweetRow?
    var statusTextView: NSAttributedStringView?
    
    let isQuotedTweetRowViewModel: Bool
    
    deinit {
        Self.count -= 1
//        print(#line, #function, "TweetRowViewModel deinited. \(Self.count) still left")
    }

    //MARK:- Methods
    init(tweetIDString: String, width: CGFloat, isQuoteded:Bool = false) {
        self.tweetIDString = tweetIDString
        self.tweetRowViewWidth = width
        ///MVVM
        self.status = StatusRepository.shared.status[tweetIDString] ?? JSON.init("")
        
        self.isQuotedTweetRowViewModel = isQuoteded

        makeViews()
        
        Self.count += 1
            }
    
  
    func makeViews() {
        retweetMarkView = makeRetweetMarkView()
        avatarView = makeAvatarView()
        userNameView = makeUserNameView()
//
        statusTextView = makeStatusTextView()
        images = makeImagesView()
        playButtonView = makePlayButtonView()
        quotedTweetRow = makeQuotedTweetRowView()


        detailIndicator = makeDetailIndicatorView()
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
    
    func makeAvatarView() -> AvatarView {
        let userIDString = status["user"]["id_str"].string ?? "0000"
        return AvatarView(userIDString: userIDString,
                          width: isQuotedTweetRowViewModel ? 18 :36,
                          height: isQuotedTweetRowViewModel ? 18 :36)
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
        return NSAttributedStringView(viewModel: viewModel, width: tweetRowViewWidth - iconColumWidth - 16 - 16)
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
        
        ///需要把quotedStatus里面的user提取出来
        let user = quotedStatus["user"]
        UserRepository.shared.addUser(user)
        
        return TweetRowViewModel(
            tweetIDString: quotedTweetIDString, width: tweetRowViewWidth - 16, isQuoteded: true )
    }
    
    func makeQuotedTweetRowView() -> QuotedTweetRow? {
        guard status["quoted_status_id_str"].string != nil else {return nil}
        
        let quotedTweetRowViewModel = makeQuotedTweetRowViewModel()
        let quotedTweetRow = QuotedTweetRow(viewModel: quotedTweetRowViewModel)
        return quotedTweetRow
    }
    
    
    func checkIsReplyToMe(userID: String?) -> Bool {
        return userID == status["in_reply_to_user_id_str"].string
    }
}
