//
//  UserInfo.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct UserInfo: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    
    var userIDString: String?
    @StateObject var checkingUser: User = User()
    @StateObject var userTimeline: Timeline = Timeline(type: .user)
    
    @State var isSettingViewShowed: Bool = false
    @State var isSettingViewIncluded: Bool = false  //是否在userInfo包含Setting页面
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                GeometryReader {
                    geometry in
                    Image(uiImage: self.checkingUser.myInfo.banner ?? UIImage(named: "bg")!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width ,height: geometry.size.height - 55)
                        .clipped()
                        .padding(0)
                }
                
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        ///个人信息大头像
                        Image(uiImage: self.checkingUser.myInfo.avatar ?? UIImage(systemName: "person.circle")!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 3))
                            .padding(.leading, 16)
                        Spacer()
                        //
                        if self.isSettingViewIncluded {
                            Image(systemName: self.isSettingViewShowed ? "arrow.uturn.backward.circle" : "gearshape")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray)
                                .font(.body)
                                .frame(width: 32, height: 32, alignment: .center)
                                .onTapGesture(count: 1, perform: {withAnimation{self.isSettingViewShowed.toggle()}
                                })
                                .padding(.trailing, 36)
                        } else {
                            Image(systemName: "envelope")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.accentColor)
                                .padding(6)
                                .frame(width: 32, height: 32, alignment: .center)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.accentColor, lineWidth: 1))
                            Image(systemName: (self.checkingUser.myInfo.notifications == true ? "bell.fill" : "bell"))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(self.checkingUser.myInfo.notifications == true ? .white : .accentColor)
                                .padding(6)
                                .frame(width: 32, height: 32, alignment: .center)
                                .background(self.checkingUser.myInfo.notifications == true ? Color.accentColor : Color.clear)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.accentColor, lineWidth: 1))
                            if self.checkingUser.myInfo.isFollowing == true {
                                Text("Following")
                                    .font(.body).bold()
                                    .frame(width: 84, height: 32, alignment: .center)
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .padding(.trailing, 16)
                                    .onTapGesture(count: 1, perform: {
                                        self.checkingUser.unfollow()
                                    })
                            } else {
                                Text("Follow")
                                    .font(.body).bold()
                                    .frame(width: 84, height: 32, alignment: .center)
                                    .background(Color.primary.opacity(0.1))
                                    .foregroundColor(.accentColor)
                                    .cornerRadius(16)
                                    .padding(.trailing, 16)
                                    .onTapGesture(count: 1, perform: {
                                        self.checkingUser.follow()
                                    })
                            }
                        }
                    }
                }.padding(0)
            }.frame(height:180)
            if self.isSettingViewShowed {
                SettingView()
            } else {
                ///用户信息View
                List {
                    VStack(alignment: .leading){
                        HStack{
                            VStack(alignment: .leading) {
                                Text(self.checkingUser.myInfo.name ?? "Name")
                                    .font(.title2).bold()
                                Text(self.checkingUser.myInfo.screenName ?? "ScreenName")
                                    .font(.body).foregroundColor(.gray)
                            }
                            Spacer()
                        }.padding(.top, 0)
                        
                        ///用户Bio信息
                        Text(self.checkingUser.myInfo.description ?? "userBio").font(.body)
                            .multilineTextAlignment(.leading)
                            .padding([.top], 16)
                        
                        ///用户位置信息
                        HStack() {
                            Image(systemName: "location.circle").resizable().aspectRatio(contentMode: .fill).frame(width: 12, height: 12, alignment: .center).foregroundColor(.gray)
                            Text(self.checkingUser.myInfo.loc ?? "Unknow").font(.caption).foregroundColor(.gray)
                            Image(systemName: "calendar").resizable().aspectRatio(contentMode: .fill).frame(width: 12, height: 12, alignment: .center).foregroundColor(.gray).padding(.leading, 16)
                            Text(self.checkingUser.myInfo.createdAt ?? "Unknow").font(.caption).foregroundColor(.gray)
                        }.padding(0)
                        
                        ///用户following信息
                        HStack {
                            Text(String(self.checkingUser.myInfo.following ?? 0)).font(.body)
                            Text("Following").font(.body).foregroundColor(.gray)
                            Text(String(self.checkingUser.myInfo.followed ?? 0)).font(.body).padding(.leading, 16)
                            Text("Followers").font(.body).foregroundColor(.gray)
                        }.padding(.bottom, 16)
                    }
                    
                    ///用户推文部分
                    ForEach(self.userTimeline.tweetIDStrings, id: \.self) {
                        tweetIDString in
                        TweetRow(timeline: self.userTimeline, tweetIDString: tweetIDString)
                    }
                    HStack {
                        Spacer()
                        Button("More Tweets...") {
                            self.userTimeline.refreshFromButtom(for: userIDString)}
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    } //下方载入更多按钮
                }.listStyle(DefaultListStyle())
            }
        }
        .onAppear(){
            self.checkingUser.myInfo.id = self.userIDString ?? "0000"
            self.checkingUser.getMyInfo()
            self.userTimeline.refreshFromTop(for: userIDString)
        }
        
    }
}

struct UserInfo_Previews: PreviewProvider {
    static var previews: some View {
        UserInfo()
    }
}

