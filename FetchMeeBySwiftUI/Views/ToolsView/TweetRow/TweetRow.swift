//
//  TweetRow.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import AVKit

struct TweetRow: View {
    //MARK:- Properties
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var loginUser: User
    
    @ObservedObject var viewModel: TweetRowViewModel
    
    var timeline: Timeline {viewModel.timeline}
    var tweetIDString: String {viewModel.tweetIDString}
    var tweetMedia: TweetMedia {viewModel.tweetMedia}
    
    var backgroundColor: Color {
        if userDefault.object(forKey: "userIDString") as? String == tweetMedia.in_reply_to_user_id_str && timeline.type == .home {
            return Color.accentColor.opacity(0.2)
        } else{ return Color.init("BackGround") }
    }
    
    @State var presentedUserInfo: Bool = false //控制显示用户信息页面
    @State var isShowDetail: Bool = false //控制显示推文详情页面
    @State var playVideo: Bool = false //控制是否显示视频播放页面
    @State var isShowAction: Bool = false //控制显示推文相关操作
    
    @State var player: AVPlayer = AVPlayer()
    
    init(viewModel: TweetRowViewModel) {
        self.viewModel = viewModel
        print(#line, #function, "TweetRowView inited")
    }
    
    
    var body: some View {
        
        VStack() {
            //如果是retweet推文，则显示retweet用户信息
            viewModel.retweetMarkView
            
            HStack(alignment: .top, spacing: 0) {
                
                //Avatar显示
                VStack {
                    viewModel.avatarView
                        .frame(width: 36, height: 36)
                        .padding(.init(top: 8, leading: 16, bottom: 12, trailing: 12))
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 0 ) {
                    
                    ///用户名和创建时间以及详情页面点点点等信息
                    HStack(alignment: .center) {
                        viewModel.userNameView

                        CreatedTimeView(createdTime: self.tweetMedia.created)
                        
                        Spacer()
                        
                        NavigationLink(destination: DetailView(tweetIDString: tweetIDString)){
                            DetailIndicator(timeline: timeline, tweetIDString: tweetIDString)
                        }
                    }
                    .padding(.top, (viewModel.retweetMarkView != nil ? 0 : 8))///根据是否有Retweet提示控制用户名和Row上边的间隙
                    
                    ///如果有回复用户列表不为空，则显示回复用户
                    viewModel.replyUsersView
//                    if tweetMedia.replyUsers.count != 0 {
//                        ReplyUsersView(replyUsers: tweetMedia.replyUsers)
//                    }
                    
                    ///推文正文
                    TweetTextView(tweetText: tweetMedia.tweetText)
                        .font(.body)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    ///如果媒体文件不为零，且用户设置显示媒体文件，则显示媒体文件视图。
                    ZStack {
                        viewModel.images
                            .cornerRadius(16)
                            .clipped()
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                        ///媒体视图上叠加一个播放按钮
                        viewModel.playButtonView
                    }
                    
                    
                    ///如果包含引用推文，则显示引用推文内容
                    viewModel.quotedTweetRow
                        .mask(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1))
//                    if let quoted_status_id_str = tweetMedia.quoted_status_id_str {
//                        QuotedTweetRow(timeline: self.timeline, tweetIDString: quoted_status_id_str)
//                            .mask(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
//                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1))
//                    }
                    
                }
                .padding(.trailing, 16)
                .onTapGesture {
                    withAnimation(){
                        viewModel.toggleToolsView()}
                }
            }
            Spacer()
            //根据isToolsViewShowed确定是否显示ToolsView
            if viewModel.isToolsViewShowed {
                ToolsView(timeline: timeline, tweetIDString: tweetIDString)
            } else {
                EmptyView()}
        }.background(backgroundColor)
        
    }
    
}



struct TweetRow_Previews: PreviewProvider {
    static let alerts = Alerts()
    static let user = User()
    static var timeline = Timeline(type: .home)
    static var tweetIDString = "0000"
    static var previews: some View {
        TweetRow(
            //            timeline: self.timeline, tweetIDString: self.tweetIDString,
            viewModel: TweetRowViewModel(timeline: Timeline(type: .home), tweetIDString: "")).environmentObject(self.alerts).environmentObject(self.user)
    }
}

