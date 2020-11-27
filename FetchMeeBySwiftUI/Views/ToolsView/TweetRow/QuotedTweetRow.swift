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
   
    @ObservedObject var timeline: Timeline
    var tweetIDString: String
    var tweetMedia: TweetMedia {self.timeline.tweetMedias[tweetIDString] ?? TweetMedia(id: "")} //生成一个计算属性用来简化
    
    
    @State var presentedUserInfo: Bool = false //控制显示用户信息页面
    @State var isShowDetail: Bool = false //控制显示推文详情页面
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 0) {
                VStack {
                    AvatarView(avatar: tweetMedia.avatar, userIDString: self.tweetMedia.userIDString)
                        .frame(width: 24, height: 24)
                        .padding(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                    Spacer()
                } //Avatar
                
                VStack(alignment: .leading, spacing: 0 ) {
                    HStack(alignment: .top) {
                        Text(self.tweetMedia.userName ?? "UnKnowName")
                            .font(.subheadline).bold()
                            .lineLimit(1)
                        Text("@" + (self.tweetMedia.screenName ?? "UnkownName"))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                        CreatedTimeView(createdTime: self.tweetMedia.created)
                        Spacer()}.padding(.top, 8)

                    if tweetMedia.replyUsers.count != 0 {
                        ReplyUsersView(replyUsers: tweetMedia.replyUsers).font(.callout)
                    }
                }
            }

            TweetTextView(tweetText: (tweetMedia.tweetText == []) ? ["This tweet is unavaliable now."] : tweetMedia.tweetText)
                .font(.callout)
                .padding(8)
                .fixedSize(horizontal: false, vertical: true)
                
            if tweetMedia.images.count != 0 && self.fetchMee.setting.isMediaShowed {
                Images(imageUrlStrings: timeline.tweetMedias[tweetIDString]?.urlStrings ?? [])
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0,  maxHeight:.infinity , alignment: .topLeading)
                    .aspectRatio(16 / 9.0, contentMode: .fill)
                    .clipped()
            } //推文图片显示区域
            }
        }
    }




struct QuotedTweetRow_Previews: PreviewProvider {
    static var previews: some View {
        TweetRow(timeline: Timeline(type: .home), tweetIDString: "")
    }
}
