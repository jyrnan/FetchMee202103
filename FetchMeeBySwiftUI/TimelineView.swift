//
//  ContentView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import SwifteriOS
import Combine


struct TimelineView: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    
    @StateObject var home = Timeline(type: TweetListType.home)
    @StateObject var mentions = Timeline(type: TweetListType.mention)
    
    @State var tweetText: String = ""

//    @State var refreshIsDone: Bool = false
    
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
//        self.user = user
//        print(#line, "ContentView \(self)")
//   let tableView = UITableView(frame: .zero, style: .insetGrouped)
    }
    
    
    var body: some View {
        
        NavigationView {
            ZStack {
                    List {
                        PullToRefreshView(action: self.refreshAll, isDone: self.$home.isDone) {
                            Composer(timeline: self.home)
                        }
                        //Mentions部分章节，
                        Section(header:HStack{
                            
                            Text("Mentions").font(.headline)
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
//                            ActivityIndicator(isAnimating: self.$home.isDone, style: .medium)
                        })
                        {
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
                            if !self.mentions.tweetIDStrings.isEmpty && self.isMentionsShowed {
                            ScrollView {
                                ForEach(self.mentions.tweetIDStrings, id: \.self) {
                                    tweetIDString in
                                    MentionRow(timeline: self.mentions, tweetIDString: tweetIDString)
                                        .padding(.bottom, 4)
                                }.listRowInsets(.init(top: 14, leading: 0, bottom: 14, trailing: 0))
                                HStack {
                                    Spacer()
                                    Button("More Tweets...") {
                                        self.mentions.refreshFromButtom()}
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding()
                                    Spacer()
                                } //下方载入更多按钮
                            }.padding(0).frame(maxHeight: 200)}
                        }
                        //Homeline部分章节
                        Section(header:HStack {
                            
                            Text("Home").font(.headline)
                                
                            
                            if self.home.newTweetNumber != 0 {
                                HStack {
                                    Image(systemName: "house.fill")
                                        .resizable().aspectRatio(contentMode: .fill).frame(width: 12, height: 12, alignment: .bottom).foregroundColor(.accentColor)
//                                        .onAppear{
//                                            if self.canOnAppearRun {
//                                            print(#line, "appear")
//                                                self.isNewTweetCountViewShowed = false}
//                                        }
//                                        .onDisappear{
//                                            print(#line, "disappear")
//                                            self.canOnAppearRun = false //需要在运行onDisppear暂时禁止onAppear运行，否则会直接运行onAPpear，原因未知
//                                            self.isNewTweetCountViewShowed = true
//                                        }
                                    Text(String(self.home.newTweetNumber))
                                        .font(.caption)
                                        .foregroundColor(.accentColor)
                                }
                            }
                            
                            Spacer()
//                            ActivityIndicator(isAnimating: self.$home.isDone, style: .medium)
                        })
                        {
                            ForEach(self.home.tweetIDStrings, id: \.self) {
                                tweetIDString in
                                TweetRow(timeline: home, tweetIDString: tweetIDString)
//                                    .listRowBackground(userDefault.object(forKey: "userIDString") as? String == self.home.tweetMedias[tweetIDString]?.in_reply_to_user_id_str ? Color.accentColor.opacity(0.2) : Color.clear) //标注被提及的推文listRowBackground
                                    .listRowBackground(userDefault.object(forKey: "userIDString") as? String == self.home.tweetMedias[tweetIDString]?.in_reply_to_user_id_str
//                                                        || self.home.tweetMedias[tweetIDString]?.isToolsViewShowed == true
                                                        ? Color.accentColor.opacity(0.1) : Color.clear) //标注被提及的或者是被选中的推文listRowBackground
                            }
                            .onDelete { indexSet in
//                                
                                let tweetIDString = self.home.tweetIDStrings[indexSet.first!]
                                swifter.destroyTweet(forID: tweetIDString, success: { _ in self.home.tweetIDStrings.remove(atOffsets: indexSet)}, failure: {_ in })
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading:0, bottom: 0, trailing: 0))
                            
                            HStack {
                                Spacer()
                                Button("More Tweets...") {
                                    self.home.refreshFromButtom()}
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                            } //下方载入更多按钮
                        }
                        
                        
                    }
                    .listStyle(InsetGroupedListStyle())
                    .onReceive(Publishers.keyboardHeight) {
                        self.keyboardHeight = $0
                        print(#line, self.keyboardHeight)
                    }
                    .offset(y: self.keyboardHeight != 0 ? -1 : 0) 
                    .navigationBarTitle("FetchMee")
                    .navigationBarItems(
//                        leading: HStack {
//                        if self.home.newTweetNumber != 0 && self.isNewTweetCountViewShowed {
//                            Text(String(self.home.newTweetNumber))}},
                                        trailing: Image(uiImage: (self.user.myInfo.avatar ?? UIImage(systemName: "person.circle.fill")!))
                                            .resizable()
                                            .frame(width: 32, height: 32, alignment: .center)
                                            .clipShape(Circle())
//                                            .onLongPressGesture {self.alerts.standAlert.isPresentedAlert.toggle() }
                                            .alert(isPresented: self.$alerts.standAlert.isPresentedAlert) {
                                                Alert(title: Text("LogOut?"), message: nil, primaryButton: .default(Text("Logout"), action: {self.logOut()}), secondaryButton: .cancel())}
                                            .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                                self.user.isShowUserInfo = true
                                            })
                                            .sheet(isPresented: self.$user.isShowUserInfo,
                                                   onDismiss: {
                                                    self.user.myInfo.setting.save()
                                            },
                                                   content: {
                                                UserInfo(userIDString: self.user.myInfo.id, isSettingViewIncluded: true).environmentObject(self.alerts)
                                                    .environmentObject(self.user).accentColor(self.user.myInfo.setting.themeColor.color)
                                            }))
                    
               
                
                VStack(spacing: 0) {
                    if self.alerts.stripAlert.isPresentedAlert {
                        AlertView(isAlertShow: self.$alerts.stripAlert.isPresentedAlert, alertText: self.alerts.stripAlert.alertText)
                    }
                    Spacer()
                } //通知视图
                .clipped() //通知条超出范围部分被裁减，产生形状缩减的效果
//                VStack {
//
//                    HStack{
//                        if self.isNewTweetCountViewShowed {
//                            Text(String(self.home.newTweetNumber))
//                                .font(.body)
//                                .foregroundColor(.accentColor)
////                                .offset(x: -150, y: -32)
//                        }
//                    }
//                    Spacer()
//                } //新推文计数器视图
            }
        }.onAppear { self.refreshAll()}
    }
}

extension TimelineView {
    
    func refreshAll() {
        print(#line, #function)
        self.home.refreshFromTop()
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

