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

    var backgroundColor: some View {
        Color.init("BackGround")
            .overlay(viewModel.isReplyToMe ? Color.accentColor.opacity(0.07) : Color.clear)}
        
       
    
    
    @State var presentedUserInfo: Bool = false //控制显示用户信息页面
    @State var isShowDetail: Bool = false //控制显示推文详情页面
    @State var playVideo: Bool = false //控制是否显示视频播放页面
    @State var isShowAction: Bool = false //控制显示推文相关操作
    
    @State var player: AVPlayer = AVPlayer()
    
    var body: some View {
        
        VStack() {
            //如果是retweet推文，则显示retweet用户信息
            viewModel.retweetMarkView
            
            HStack(alignment: .top, spacing: 0) {
                
                //Avatar显示
                VStack {
                    viewModel.avatarView
//                        .frame(width: 36, height: 36)
                        .padding(.init(top: 8, leading: 0, bottom: 12, trailing: 12))
                    Spacer()
                }
                .frame(width: viewModel.iconColumWidth)
//                .background(Color.red)
                
                VStack(alignment: .leading, spacing: 0 ) {
                    
                    ///用户名和创建时间以及详情页面点点点等信息
                    HStack(alignment: .center) {
                        viewModel.userNameView
                        
                        CreatedTimeView(createdTime: viewModel.status["created_at"].string)
                        
                        Spacer()
//                        ZStack{
//                            NavigationLink(destination: DetailView(tweetIDString: viewModel.tweetIDString)){EmptyView()}
                        viewModel.detailIndicator.background(Color.init("BackGround"))
//                        }
//                        }
//                        .background(Color.blue)
                        
                    }
                    .padding(.top, (viewModel.retweetMarkView != nil ? 0 : 4))///根据是否有Retweet提示控制用户名和Row上边的间隙
                    
                    ///推文主界面
                    viewModel.statusTextView?.padding(.top, 8)
//                        .background(Color.green)
                    
                    ///如果媒体文件不为零，且用户设置显示媒体文件，则显示媒体文件视图。
                    ZStack {
                        viewModel.images
                            .cornerRadius(16)
                            .clipped()
                        
                        ///媒体视图上叠加一个播放按钮
                        viewModel.playButtonView
                    }
                    .padding(.top, 4)
                    
                    ///如果包含引用推文，则显示引用推文内容
                    viewModel.quotedTweetRow
                        .padding(.top, 4)
                }
//                .background(Color.orange)
//                .onTapGesture {
//                    withAnimation(){  viewModel.toggleToolsView()}
//                }
                
            }
            
//            Rectangle()
//                .padding(0)
//                .foregroundColor(.clear)
//                .frame(height: 16)
//                .contentShape(Rectangle())
//                .onTapGesture {
//                    withAnimation(){  viewModel.toggleToolsView()}
//                }
//            viewModel.toolsVeiw
        }
//        .background(backgroundColor)
        
    }
    
}


