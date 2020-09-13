//
//  ContentView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine
import UIKit


struct TimelineView: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    @EnvironmentObject var downloader: Downloader
    
    @StateObject var home = Timeline(type: TweetListType.home)
    @StateObject var mentions = Timeline(type: TweetListType.mention)
    
    @State var tweetText: String = ""
    
    @State var keyboardHeight: CGFloat = 0 //用来观察键盘是否弹出，如果键盘弹出，会赋值给这个键盘，也就是不会为0
    
    @State var isMentionsShowed: Bool = false
    @State var isSettingShowed: Bool = false
    @State var isNewTweetCountViewShowed: Bool = false
    @State var canOnAppearRun: Bool = true {
        didSet {
            delay(delay: 1, closure: {self.canOnAppearRun = true})
        }
    }
    init() {
    }
    
    
    var body: some View {
        
        NavigationView {
            ZStack {
                ScrollView(.vertical) {
                    PullToRefreshView(action: self.refreshAll, isDone: self.$home.isDone) {
                        Composer(timeline: self.home)}.frame(height: 36).background(Color.init("BackGround")).cornerRadius(18).padding([.leading, .trailing], 16)
                    
                    //Mentions部分章节，
                    HStack{
                        Text("MENTIONS").font(.headline).foregroundColor(Color.gray)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    self.isMentionsShowed.toggle() }
                            }
                        if self.mentions.newTweetNumber != 0 {
                            Image(systemName: "bell.fill").resizable().aspectRatio(contentMode: .fill).frame(width: 12, height: 12, alignment: .bottom).foregroundColor(.accentColor)
                            Text(String(self.mentions.newTweetNumber))
                                .font(.caption)
                                .foregroundColor(.accentColor)
                        }
                        Spacer()
                        if !self.mentions.mentionUserIDStringsSorted.isEmpty && self.isMentionsShowed && self.user.myInfo.setting.isIronFansShowed {
                            HStack(alignment: .center) {
                                MentionUserSortedView(mentions: self.mentions)
                                Image(systemName: "xmark.circle").resizable().aspectRatio(contentMode: .fill).frame(width: 18, height: 18, alignment: .center)
                                    .foregroundColor(.gray)
                                    .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                        withAnimation{
                                            self.user.myInfo.setting.isIronFansShowed = false}
                                    })
                            }}
                        
                    }.padding(.top, 8).padding([.leading, .trailing], 16)
                    
                    if !self.mentions.tweetIDStrings.isEmpty && self.isMentionsShowed {
                        ScrollView {
                            ZStack {
                                Color.init("BackGround")
                                LazyVStack(spacing: 0) {
                                    ForEach(self.mentions.tweetIDStrings, id: \.self) {
                                        tweetIDString in
                                        MentionRow(timeline: self.mentions, tweetIDString: tweetIDString)
                                        
                                    }
                                    HStack {
                                        Spacer()
                                        Button("More Tweets...") {
                                            self.mentions.refreshFromButtom()}
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .padding()
                                        Spacer()
                                    } //下方载入更多按钮
                                }
                            }
                        }.padding(0).frame(maxHeight: 220).cornerRadius(16).padding([.leading, .trailing], 16)
                        
                    }
                    
                    //Homeline部分章节
                    HStack {
                        Text("HOME").font(.headline).foregroundColor(Color.gray)
                        
                        if self.home.newTweetNumber != 0 {
                            HStack {
                                Image(systemName: "house.fill")
                                    .resizable().aspectRatio(contentMode: .fill).frame(width: 12, height: 12, alignment: .bottom).foregroundColor(.accentColor)
                                Text(String(self.home.newTweetNumber))
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        Spacer()
                    }.padding(.top, 8).padding([.leading, .trailing], 16)
                    
                    LazyVStack(spacing: 0) {
                        RoundedCorners(color: Color.init("BackGround"), tl: 18, tr: 18 ).frame(height: 18)
                        ForEach(self.home.tweetIDStrings, id: \.self) {
                            tweetIDString in
                            TweetRow(timeline: home, tweetIDString: tweetIDString).background(userDefault.object(forKey: "userIDString") as? String == self.home.tweetMedias[tweetIDString]?.in_reply_to_user_id_str ? Color.accentColor.opacity(0.2) : Color.init("BackGround")) //标注被提及的推文listRowBackground
                            Divider()
                        }
                        HStack {
                            Spacer()
                            Button("More Tweets...") {self.home.refreshFromButtom()}
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(height: 24)
                            Spacer()
                        }.background(Color.init("BackGround")) //下方载入更多按钮
                        RoundedCorners(color: Color.init("BackGround"), bl: 18, br: 18 ).frame(height: 18)
                    }.padding([.leading, .trailing], 16)
                    
                }
                .navigationBarTitle("FetchMee")
                .navigationBarItems(leading:
                                        HStack{
                                            if downloader.taskCount != 0 {
                                            Text("\(downloader.taskCount) pictures downloading...")
                                                .font(.caption).foregroundColor(.gray)
                                            }
                                        },
                    trailing:
                                        NavigationLink(destination: SettingView()) {
                                                Image(uiImage: (self.user.myInfo.avatar ?? UIImage(systemName: "person.circle.fill")!))
                                                    .resizable()
                                                    .frame(width: 32, height: 32, alignment: .center)
                                                    .clipShape(Circle())
                                                
                                            })
                
                VStack(spacing: 0) {
                    if self.alerts.stripAlert.isPresentedAlert {
                        AlertView(isAlertShow: self.$alerts.stripAlert.isPresentedAlert, alertText: self.alerts.stripAlert.alertText)
                    }
                    Spacer()
                } //通知视图
                .clipped() //通知条超出范围部分被裁减，产生形状缩减的效果
            }
        }.onAppear { self.refreshAll()} //进入界面刷新一次
    }
}

extension TimelineView {
    /**
     处理出错的handler，可以传入到timeline里面执行。
     */
    func failureHandler(error: Error) -> Void {
        print(#line, error.localizedDescription)
        self.alerts.stripAlert.alertText = "Sorry! Network error!"
        self.alerts.stripAlert.isPresentedAlert = true
    }
    
    func refreshAll() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred() //产生震动提示
        self.home.refreshFromTop(fh: failureHandler(error:))
        self.mentions.refreshFromTop()
    }
    
    func logOut() {
        self.user.isLoggedIn = false
        userDefault.set(false, forKey: "isLoggedIn")
        userDefault.set(nil, forKey: "userIDString")
        userDefault.set(nil, forKey: "screenName")
        userDefault.set(nil, forKey: "mentionUserInfo")
        print(#line)
    }
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}

