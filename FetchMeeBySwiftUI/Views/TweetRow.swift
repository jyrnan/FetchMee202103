//
//  TweetRow.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

struct TweetRow: View {
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
                        .frame(width: 36, height: 36)
                        .padding(.init(top: 12, leading: 0, bottom: 12, trailing: 12))
                    Spacer()
                } //Avatar
                
                VStack(alignment: .leading, spacing: 0 ) {
                    if self.tweetMedia.retweeted_by_UserName != nil {
                        HStack {
                            Image(systemName:"repeat")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12, alignment: .center)
                                .foregroundColor(.gray)
                            Text(self.tweetMedia.retweeted_by_UserName! + "  retweeted")
                            .font(.caption2)
                            .foregroundColor(.gray)
                                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                    self.presentedUserInfo = true
                                })
                                .sheet(isPresented: $presentedUserInfo) {UserInfo(userIDString: self.tweetMedia.retweeted_by_UserIDString).environmentObject(self.alerts)
                                    .environmentObject(self.user)}
                            Spacer()
                        }.offset(x: -20)
                    }
                    HStack(alignment: .center) {
                        Text(self.tweetMedia.userName ?? "UserName")
                            .font(.headline)
                            .lineLimit(1)
                        Text("@" + (self.tweetMedia.screenName ?? "screenName"))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                        CreatedTimeView(createdTime: self.tweetMedia.created!)
                        Spacer()
                        DetailIndicator(timeline: timeline, tweetIDString: tweetIDString)
                            .padding(.all, 0)
                            .onTapGesture {self.isShowDetail = true}
                            .sheet(isPresented: self.$isShowDetail) {DetailView(tweetIDString: tweetIDString, isShowDetail: self.$isShowDetail).environmentObject(self.alerts).environmentObject(self.user)}
                        } //用户名和创建时间以及详情页面点点点等信息
                    if tweetMedia.replyUsers.count != 0 {
                        ReplyUsersView(replyUsers: tweetMedia.replyUsers)
                    }
                    TweetTextView(tweetText: tweetMedia.tweetText)
                        .font(.body)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                        .fixedSize(horizontal: false, vertical: true)
                        .onTapGesture {
                            if let prev = self.timeline.tweetIDStringOfRowToolsViewShowed {
                                if prev != tweetIDString {self.timeline.tweetMedias[prev]?.isToolsViewShowed = false}
                            }
                            withAnimation {self.timeline.tweetMedias[tweetIDString]?.isToolsViewShowed.toggle() }
                            self.timeline.tweetIDStringOfRowToolsViewShowed = tweetIDString
                        } //实现点击出现ToolsVIew快速回复

                    if tweetMedia.images.count != 0 {
                        Images(images: self.tweetMedia.images)
                            .frame(height: 160, alignment: .center)
                            .cornerRadius(16)
                            .clipped()
                            .padding(.top, 16)
                            .padding(.bottom, 16)
                    } //推文图片显示区域
                    
                    if tweetMedia.quoted_status_id_str != nil {
                        QuotedTweetRow(timeline: self.timeline, tweetIDString: tweetMedia.quoted_status_id_str!).mask(RoundedRectangle(cornerRadius: 16, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                                      .stroke(Color.gray
                                                                                .opacity(0.2), lineWidth: 1))
                    }
//                   
                }
            } //推文内容
            Spacer()
            if self.timeline.tweetMedias[tweetIDString]!.isToolsViewShowed {
                ToolsView(timeline: timeline, tweetIDString: tweetIDString)
            }
        }
    }
}



struct TweetRow_Previews: PreviewProvider {
    static var previews: some View {
        TweetRow(timeline: Timeline(type: .home), tweetIDString: "")
    }
}
