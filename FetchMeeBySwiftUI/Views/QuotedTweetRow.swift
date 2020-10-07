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
    @EnvironmentObject var user: User
   
    @ObservedObject var timeline: Timeline
    var tweetIDString: String
    var tweetMedia: TweetMedia {self.timeline.tweetMedias[tweetIDString] ?? TweetMedia(id: "")} //生成一个计算属性用来简化
    
    
    @State var presentedUserInfo: Bool = false //控制显示用户信息页面
    @State var isShowDetail: Bool = false //控制显示推文详情页面
    
    var body: some View {
        VStack() {
            HStack(alignment: .top, spacing: 0) {
                VStack {
                    AvatarView(avatar: self.tweetMedia.avatar!, userIDString: self.tweetMedia.userIDString)
                        .frame(width: 32, height: 32)
                        .padding(.init(top: 12, leading: 4, bottom: 12, trailing: 12))
                    Spacer()
                } //Avatar
                
                VStack(alignment: .leading, spacing: 0 ) {
                    HStack(alignment: .center) {
                        Text(self.tweetMedia.userName ?? "UnKnowName")
                            .font(.headline)
                            .lineLimit(1)
                        Text("@" + (self.tweetMedia.screenName ?? "UnkownName"))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                        CreatedTimeView(createdTime: self.tweetMedia.created)
                        Spacer()}

                    if tweetMedia.replyUsers.count != 0 {
                        ReplyUsersView(replyUsers: tweetMedia.replyUsers)
                    }
                    TweetTextView(tweetText: (tweetMedia.tweetText == []) ? ["This tweet is unavaliable now."] : tweetMedia.tweetText)
                        .font(.body)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        .fixedSize(horizontal: false, vertical: true)
                        .onTapGesture {
                            if let prev = self.timeline.tweetIDStringOfRowToolsViewShowed {
                                if prev != tweetIDString {self.timeline.tweetMedias[prev]?.isToolsViewShowed = false}
                            }
                            withAnimation {self.timeline.tweetMedias[tweetIDString]?.isToolsViewShowed.toggle() }
                            self.timeline.tweetIDStringOfRowToolsViewShowed = tweetIDString
                        }
                }
            }.scaleEffect(0.9) //推文内容
            if tweetMedia.images.count != 0 && self.user.myInfo.setting.isMediaShowed {
                Images(timeline: self.timeline, tweetIDString: self.tweetIDString)
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
