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


struct ContentView: View {
    @EnvironmentObject var alerts: Alerts
    
    @ObservedObject var home = Timeline(type: TweetListType.home)
    @ObservedObject var mentions = Timeline(type: TweetListType.mention)
    @ObservedObject var kGuardianOfContentView: KeyboardGuardian = KeyboardGuardian(textFieldCount: 2)
    
    @ObservedObject var user: User
    @State var tweetText: String = ""
    
    @State var isFirstRun: Bool = true //设置用于第一次运行刷新的时候标志
    @State var isHiddenMention: Bool = false //用于控制Mentions Section是否隐藏内容
    @State var refreshIsDone: Bool = false
    
    var body: some View {
        NavigationView{
            ZStack {
                if #available(iOS 14.0, *) {
                    List {
                        PullToRefreshView(action: self.refreshAll, isDone: self.$home.isDone) {
                            Composer(timeline: self.home)
                                .background(GeometryGetter(rect: self.$kGuardianOfContentView.rects[1]))
                        }
                        //Mentions部分章节，
                        Section(header:HStack {
                                        Button(action: { self.isHiddenMention.toggle() },
                                               label: {Text(self.mentions.newTweetNumber == 0 ? "Mentions" : "Mentions \(self.mentions.newTweetNumber)").font(.headline)})
                                        ActivityIndicator(isAnimating: self.$home.isDone, style: .medium)
                                        Spacer()
                                        
                                        if !self.isHiddenMention {
                                            Button(action: {self.mentions.refreshFromTop()}, label: {
                                                Image(systemName: "arrow.clockwise")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 18, height: 18)
                                                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 4)
                                            })
                                        }
                                    }) //两个Button组成，第一个Button能控制是否隐藏内容
                        {
                            if !isHiddenMention {
                                TweetsList(timeline: self.mentions, kGuardian: self.kGuardianOfContentView, tweetListType: TweetListType.mention)
                                HStack {
                                    Spacer()
                                    Button("More Tweets...") {
                                        self.mentions.refreshFromButtom()}
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                } //下方载入更多按钮
                            }
                        }
                        //Homeline部分章节
                        Section(header:HStack {
                                        Text(self.home.newTweetNumber == 0 ? "Homeline" : "Homeline \(self.home.newTweetNumber)").font(.headline)
                                        ActivityIndicator(isAnimating: self.$home.isDone, style: .medium)
                                        Spacer()
                                        Button(action: {self.home.refreshFromTop()}, label: {
                                            Image(systemName: "arrow.clockwise")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 18, height: 18)
                                                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 4)
                                        })
                                    })
                        {
                            TweetsList(timeline: self.home, kGuardian: self.kGuardianOfContentView, tweetListType: TweetListType.home)
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
                    .offset(y: kGuardianOfContentView.slide).animation(.easeInOut(duration: 0.2))
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle("FetchMee")
                    .navigationBarItems(trailing: Image(uiImage: (self.user.myInfo.avatar ?? UIImage(systemName: "person.circle.fill")!))
                                            .resizable()
                                            .frame(width: 32, height: 32, alignment: .center)
                                            .clipShape(Circle())
                                            .onLongPressGesture {self.alerts.standAlert.isPresentedAlert.toggle() }
                                            .alert(isPresented: self.$alerts.standAlert.isPresentedAlert) {
                                                Alert(title: Text("LogOut?"), message: nil, primaryButton: .default(Text("Logout"), action: {self.logOut()}), secondaryButton: .cancel())})
                } else {
                    // Fallback on earlier versions
                }
                
                VStack(spacing: 0) {
                    if self.alerts.stripAlert.isPresentedAlert {
                        AlertView(isAlertShow: self.$alerts.stripAlert.isPresentedAlert, alertText: self.alerts.stripAlert.alertText)
                    }
                    Spacer()
                } //通知视图
                .clipped() //通知条超出范围部分被裁减，产生形状缩减的效果
            }
        }
        .onAppear{
            print(#line, "added observer")
            self.kGuardianOfContentView.addObserver()}
        .onDisappear { self.kGuardianOfContentView.removeObserver() }
    }
}

extension ContentView {
    
    func refreshAll() {
        self.home.refreshFromTop()
        self.mentions.refreshFromTop()
    }
    
    func logOut() {
        self.user.isLoggedIn = false
        userDefault.set(false, forKey: "isLoggedIn")
        userDefault.set(nil, forKey: "userIDString")
        userDefault.set(nil, forKey: "screenName")
        print(#line)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(user: User())
    }
}

