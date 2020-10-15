//
//  SettingView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/8/8.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

struct SettingView: View {
    @EnvironmentObject var user: User
    @StateObject var timeline: Timeline = Timeline(type: .user)
    
    @State var isPresentedAlert: Bool = false //显示确认退出alertView
    var checkingUser: User {self.user} //使用用户和chckingUser是同一个
    
    var body: some View {
        Form {
            
            ZStack {VStack {
                Spacer()
                Image(uiImage: self.checkingUser.myInfo.banner ?? UIImage(named: "bg")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 100)
                    .clipped()
                    .padding(0)
            }
                
                HStack {
                    Spacer()
                Image(uiImage: (self.user.myInfo.avatar ?? UIImage(systemName: "person.circle.fill")!))
                .resizable()
                .frame(width: 64, height: 64, alignment: .center)
                    .overlay(Circle().stroke(Color.gray.opacity(0.7), lineWidth: 2))
                .clipShape(Circle())
                    .offset(y: -25)
                    .padding(.trailing, 32)
                    .shadow(radius: 6)
                }
            }
            .frame(height: 150)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            Section(header: Text("Visual"), footer: Text("You can swith this function off to get a simper UI and better performance")) {
                
                Picker("Favorit Theme Color", selection: self.$user.myInfo.setting.themeColor, content: {
                    ForEach(ThemeColor.allCases){color in
                        Text(color.rawValue.capitalized).tag(color)
                    }
                })
                Toggle("Iron Fans Rate", isOn: self.$user.myInfo.setting.isIronFansShowed)
                Toggle("Show Pictures", isOn: self.$user.myInfo.setting.isMediaShowed)
//                Toggle("Delete All Tweets", isOn: self.$user.myInfo.setting.isDeleteTweets)
            }
            
//            Section(header:Text("Other")){
//                NavigationLink(destination: DeleteTweetsView(timeline: self.timeline), label: {Text("Bunk Delete Tweets")})
//                NavigationLink(destination: DeleteTweetsView(timeline: self.timeline), label: {Text("Place Holder")})
//                NavigationLink(destination: DeleteTweetsView(timeline: self.timeline), label: {Text("Place Holder")})
//                NavigationLink(destination: DeleteTweetsView(timeline: self.timeline), label: {Text("Place Holder")})
//            }
            
            Section(header:Text("")){
                HStack {
                    Spacer()
                    Text("Clean Cache")
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    Button("Login out"){
                        self.isPresentedAlert = true
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .alert(isPresented: self.$isPresentedAlert) {
                        Alert(title: Text("Login Out?"), message: nil, primaryButton: .default(Text("Logout"), action: {self.logOut()}), secondaryButton: .cancel())}
                    Spacer()
                }.listRowBackground(Color.accentColor)
                HStack {
                    Spacer()
                    Text("FetchMee Developed by @jyrnan").font(.caption).foregroundColor(.gray)
                    Spacer()
                }
            }
        }
        .onDisappear{self.user.myInfo.setting.save()}
        .navigationTitle("Setting")
    }
}

extension SettingView {
    
    func logOut() {
        self.user.isShowUserInfo = false
        self.user.myInfo = UserInfomation() //  设置成一个空的userInfo
        print(#line, self.user.isShowUserInfo)
        delay(delay: 1, closure: {
            withAnimation {
                
                userDefault.set(false, forKey: "isLoggedIn")
                userDefault.set(nil, forKey: "userIDString")
                userDefault.set(nil, forKey: "screenName")
                userDefault.set(nil, forKey: "mentionUserInfo")
                self.user.isLoggedIn = false
            }
        })
    }
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var user: User = User()
//    static var timeline = Timeline(type: .user)
    static var previews: some View {
        NavigationView {
            SettingView().environmentObject(user)
        }
    }
}
