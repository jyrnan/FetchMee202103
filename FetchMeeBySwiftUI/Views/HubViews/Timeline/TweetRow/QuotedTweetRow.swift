//
//  TweetRow.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

struct QuotedTweetRow: View {
    @EnvironmentObject var alerts: Alerts
//    @EnvironmentObject var fetchMee: User
    
    @ObservedObject var viewModel: TweetRowViewModel
    
    @State var presentedUserInfo: Bool = false //控制显示用户信息页面
    @State var isShowDetail: Bool = false //控制显示推文详情页面
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 0) {
                VStack {
                    viewModel.avatarView
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        
                        .padding(.init(top: 8, leading: 8, bottom: 0, trailing: 8))
                    Spacer()
                } //Avatar
                
                VStack(alignment: .leading, spacing: 0 ) {
                    HStack(alignment: .top) {
                        viewModel.userNameView
                        CreatedTimeView(createdTime: viewModel.status["created_at"].string)
                        Spacer()
                    }
                    .padding(.top, 8)
                    ///replyUser
                }
            }
            
            HStack{
                Spacer()
                viewModel.statusTextView.padding(.top, 4)
                Spacer()
            }
            
            ZStack {
            viewModel.images//推文图片显示区域
            viewModel.playButtonView
            }
        }
        .mask(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}
