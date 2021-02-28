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
    @EnvironmentObject var store: Store
    
    @ObservedObject var viewModel: TweetRowViewModel
    
    var backgroundColor: some View {
        Color.init("BackGround")
            .overlay(isSelected ? Color.accentColor.opacity(0.12) : (
                        isReplyToMe ? Color.accentColor.opacity(0.05) : Color.clear))
    }
    
    @State var presentedUserInfo: Bool = false //控制显示用户信息页面
    @State var isShowDetail: Bool = false //控制显示推文详情页面
    @State var playVideo: Bool = false //控制是否显示视频播放页面
    
    private var isSelected: Bool {viewModel.tweetIDString == store.appState.timelineData.tweetIDStringOfRowToolsViewShowed} //控制显示推文相关操作
    private var isReplyToMe: Bool {viewModel.checkIsReplyToMe(userID: store.appState.setting.loginUser?.id)}

    
    @State var player: AVPlayer = AVPlayer()
    
    init(viewModel:TweetRowViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack {
            
                VStack(spacing: 0){
                    //如果是retweet推文，则显示retweet用户信息
                    viewModel.retweetMarkView?.padding(.top, 8)
                    
                    HStack(alignment: .top, spacing: 0) {
                        
                        //Avatar显示
                        VStack {
                            
                            viewModel.avatarView
                                .padding(.init(top: 8, leading: 0, bottom: 12, trailing: 12))
                            Spacer()
                        }
                        .frame(width: viewModel.iconColumWidth)
                        
                        VStack(alignment: .leading) {
                            
                            ///用户名和创建时间以及详情页面点点点等信息
                            HStack(alignment: .center) {
                                viewModel.userNameView
                                
                                CreatedTimeView(createdTime: viewModel.status["created_at"].string)
                                
                                Spacer()
                                ZStack{
                                    
                                    NavigationLink(destination: DetailViewRedux(tweetIDString: viewModel.tweetIDString), isActive:$isShowDetail , label:{EmptyView()} ).opacity(0.1).disabled(true)
                                    viewModel.detailIndicator
                                        .onTapGesture {
                                            store.dipatch(.fetchSession(tweetIDString: viewModel.tweetIDString))
                                            isShowDetail = true }
                    
                                }.fixedSize()
                                
                            }
                           
                            ///推文主界面
                            viewModel.statusTextView
                                .onTapGesture {
                                    withAnimation{store.dipatch(.selectTweetRow(tweetIDString: viewModel.tweetIDString))}
                                    
                                }
                            
                            ///如果媒体文件不为零，且用户设置显示媒体文件，则显示媒体文件视图。
                            ZStack {
                                viewModel.images
                                    .cornerRadius(16)
                                    .clipped()
                                
                                ///媒体视图上叠加一个播放按钮
                                viewModel.playButtonView
                            }
                            
                            ///如果包含引用推文，则显示引用推文内容
                            viewModel.quotedTweetRow
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                }.animation(.none)
          
            
//            if isSelected {
//                viewModel.toolsView
//            }
        }
        .listRowBackground(backgroundColor)
//        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        
    }
    
}


