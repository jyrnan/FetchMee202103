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
    @EnvironmentObject var fetchMee: User
    
    @ObservedObject var viewModel: TweetRowViewModel
    
//    var timeline: Timeline {viewModel.timeline}
//    var tweetIDString: String {viewModel.tweetIDString}
//    var tweetMedia: TweetMedia {viewModel.tweetMedia}
    
    
    @State var presentedUserInfo: Bool = false //控制显示用户信息页面
    @State var isShowDetail: Bool = false //控制显示推文详情页面
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 0) {
                VStack {
                    viewModel.avatarView
                        .frame(width: 18, height: 18)
                        .padding(.init(top: 8, leading: 8, bottom: 0, trailing: 8))
                    Spacer()
                } //Avatar
                
                VStack(alignment: .leading, spacing: 0 ) {
                    HStack(alignment: .top) {
                        viewModel.userNameView
                        CreatedTimeView(createdTime: viewModel.tweetMedia.created)
                        Spacer()
                    }
                    .padding(.top, 8)
                    ///replyUser
                    viewModel.replyUsersView
                }
            }
            
            TweetTextView(tweetText: (viewModel.tweetMedia.tweetText == []) ? ["This tweet is unavaliable now."] : viewModel.tweetMedia.tweetText)
                .font(.callout)
                .padding(8)
                .fixedSize(horizontal: false, vertical: true)
            
            viewModel.images//推文图片显示区域
        }
    }
}




struct QuotedTweetRow_Previews: PreviewProvider {
    static var previews: some View {
        TweetRow(viewModel: TweetRowViewModel(timeline: Timeline(type: .home), tweetIDString: "tweetIDString)"))
    }
}
