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
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    
    @ObservedObject var timeline: Timeline
    var tweetIDString: String
    var tweetMedia: TweetMedia {self.timeline.tweetMedias[tweetIDString] ?? TweetMedia(id: "0000")} //生成一个计算属性用来简化，如果没有相应TweetMedia则生成一个缺省的
    
    
    @State var presentedUserInfo: Bool = false //控制显示用户信息页面
    @State var isShowDetail: Bool = false //控制显示推文详情页面
    @State var playVideo: Bool = false //控制是否显示视频播放页面
    @State var isShowAction: Bool = false //控制显示推文相关操作
    
    @State var player: AVPlayer = AVPlayer()
    
    var body: some View {
        VStack() {
            if self.tweetMedia.retweeted_by_UserName != nil {
                HStack {
                    Image(systemName:"repeat")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12, alignment: .center)
                        .foregroundColor(.gray)
                    Text(self.tweetMedia.retweeted_by_UserName! + "  retweeted")
                        .font(.subheadline).lineLimit(2)
                        .foregroundColor(.gray)
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            self.presentedUserInfo = true
                        })
                        .sheet(isPresented: $presentedUserInfo) {UserInfo(userIDString: self.tweetMedia.retweeted_by_UserIDString).environmentObject(self.alerts)
                            .environmentObject(self.user)}
                    Spacer()
                }.offset(x: 44).padding(.top, 8).padding(.bottom, 0)
            }
            HStack(alignment: .top, spacing: 0) {
                
                VStack {
                    AvatarView(avatar: self.tweetMedia.avatar!, userIDString: self.tweetMedia.userIDString, userName: self.tweetMedia.userName, screenName: self.tweetMedia.screenName, tweetIDString: self.tweetIDString)
                        .frame(width: 36, height: 36)
                        .padding(.init(top: 8, leading: 16, bottom: 12, trailing: 12))
                    Spacer()
                } //Avatar
                
                VStack(alignment: .leading, spacing: 0 ) {
                    
                    //用户名和创建时间以及详情页面点点点等信息
                    HStack(alignment: .center) {
                        Text(self.tweetMedia.userName ?? "UserName")
                            .font(.headline)
                            .lineLimit(1)
                        Text("@" + (self.tweetMedia.screenName ?? "screenName"))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                        CreatedTimeView(createdTime: self.tweetMedia.created)
                        Spacer()
                        DetailIndicator(timeline: timeline, tweetIDString: tweetIDString)
                            .padding(.all, 0)
                            .contentShape(Rectangle())
                            .onTapGesture {self.isShowDetail = true}
                            .sheet(isPresented: self.$isShowDetail) {DetailView(tweetIDString: tweetIDString, isShowDetail: self.$isShowDetail).environmentObject(self.alerts).environmentObject(self.user).accentColor(self.user.myInfo.setting.themeColor.color)}
                    }
                    .padding(.top, (self.tweetMedia.retweeted_by_UserName != nil ? 0 : 8))///根据是否有Retweet提示控制用户名和Row上边的间隙
                    
                    //如果有回复用户列表不为空，则显示回复用户
                    if tweetMedia.replyUsers.count != 0 {ReplyUsersView(replyUsers: tweetMedia.replyUsers)}
                    
                    //推文正文
                    TweetTextView(tweetText: tweetMedia.tweetText)
                        .font(.body)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                        .fixedSize(horizontal: false, vertical: true)
                        .onTapGesture {//通过点击推文正文来实现
                            if let prev = self.timeline.tweetIDStringOfRowToolsViewShowed {
                                if prev != tweetIDString {self.timeline.tweetMedias[prev]?.isToolsViewShowed = false} //判断如果先前选定显示ToolsView的tweetID不是自己，则将原激活ToolSView的推文取消激活
                            }
                            withAnimation {self.timeline.tweetMedias[tweetIDString]?.isToolsViewShowed.toggle() }
                            self.timeline.tweetIDStringOfRowToolsViewShowed = tweetIDString
                        } //实现点击出现ToolsVIew快速回复
                        .onLongPressGesture {
                            self.isShowAction = true
                        }
                        
                        .actionSheet(isPresented: self.$isShowAction, content: {
                            ActionSheet(title: Text("Tweet"), message: Text("What do you wanna to do with this tweet"), buttons: [
                                            .destructive(Text("Delete"), action: {}),
                                            .default(Text("Retweet"), action: {}),
                                            .default(Text("Delete"), action: {}),
                                            .cancel()])
                        })
                    
                    
                    if tweetMedia.images.count != 0 && self.user.myInfo.setting.isMediaShowed {//如果媒体文件不为零，且用户设置显示媒体文件，则显示媒体文件视图。
                        ZStack {
                            Images(timeline: self.timeline, tweetIDString: self.tweetIDString)
                                .frame(height: 160, alignment: .center)
                                .cornerRadius(16)
                                .clipped()
                                .padding(.top, 8)
                                .padding(.bottom, 8)
                            
                            //媒体视图上叠加一个播放按钮
                            if (tweetMedia.mediaType == "video" || tweetMedia.mediaType == "animated_gif") {
                                Image(systemName: "play.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 64, height: 64, alignment: .center)
                                    .foregroundColor(.white).opacity(0.7)
                                    .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                                        
                                        Button(action: {self.timeline.videoDownloader(from: self.tweetMedia.mediaUrlString,
                                                                                      sh: {self.alerts.stripAlert.alertText = "Vedio saved!"
                                                                                        self.alerts.stripAlert.isPresentedAlert = true
                                                                                        print("Video is saved!")
                                                                                      },
                                                                                      fh: {self.alerts.stripAlert.alertText = "Vedio Not Saved!"
                                                                                        self.alerts.stripAlert.isPresentedAlert = true
                                                                                        print("Video is unSaved!")
                                                                                      })}, label: {
                                                Text("Save Video")
                                            Image(systemName: "folder")
                                        })
                                       
                                    }/*@END_MENU_TOKEN@*/)
                                    .onTapGesture(count: 1, perform: {
                                        if self.playVideo {
                                            self.player = AVPlayer()
                                            self.playVideo = false
                                        } else {
                                            if let url = self.tweetMedia.mediaUrlString {
                                        self.player = AVPlayer(url: URL(string: url)!)
                                                self.playVideo = true }
                                        }
                                    })
                                    .fullScreenCover(isPresented: self.$playVideo, onDismiss: {self.player = AVPlayer()}, content: {
                                        PlayerContainerView(player: self.player)
                                    })
                            }
                        }
                    } //推文图片或视频显示区域
                    
                    if let quoted_status_id_str = tweetMedia.quoted_status_id_str {
                        QuotedTweetRow(timeline: self.timeline, tweetIDString: quoted_status_id_str)
                            .mask(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    }
                    //
                }.padding(.trailing, 16)
            }//推文内容
            Spacer()
            //根据isToolsViewShowed确定是否显示ToolsView
            if self.tweetMedia.isToolsViewShowed {
                ToolsView(timeline: timeline, tweetIDString: tweetIDString)
            } else {
                EmptyView()}
//                Divider().padding(0)}
        }
    }
}



struct TweetRow_Previews: PreviewProvider {
    static let alerts = Alerts()
    static let user = User()
    static var timeline = Timeline(type: .home)
    static var tweetIDString = "0000"
    static var previews: some View {
        TweetRow(timeline: self.timeline, tweetIDString: self.tweetIDString).environmentObject(self.alerts).environmentObject(self.user)
    }
}
