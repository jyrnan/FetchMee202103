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
    @EnvironmentObject var fetchMee: AppData
    
    @State var isPresentedAlert: Bool = false //显示确认退出alertView
    
    var body: some View {
        Form {
                Image(uiImage: fetchMee.users[fetchMee.loginUserID]?.banner ?? UIImage(named: "bg")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            .frame(height: 120)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            Section(header: Text("Visual"),
                    footer: Text("You can swith this function off to get a simper UI and better performance")) {
                
                Picker("Favorit Theme Color", selection: self.$fetchMee.setting.themeColor, content: {
                    ForEach(ThemeColor.allCases){color in
                        Text(color.rawValue.capitalized).tag(color)
                    }
                })
                
                Toggle("Iron Fans Rate", isOn: self.$fetchMee.setting.isIronFansShowed)
                Toggle("Show Pictures", isOn: self.$fetchMee.setting.isMediaShowed)
            }
            
            Section(header:Text("Other")){
                
                NavigationLink(destination: ComposerOfHubView(tweetText: .constant("")), label: {Text("Place Holder")})
                NavigationLink(destination: ComposerOfHubView(tweetText: .constant("")), label: {Text("Place Holder")})
                NavigationLink(destination: ComposerOfHubView(tweetText: .constant("")), label: {Text("Place Holder")})
            }
            
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
        .onDisappear{fetchMee.setting.save()}
        .navigationTitle("Setting")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems( trailing: AvatarImageView(image: fetchMee.users[fetchMee.loginUserID]?.avatar).frame(width: 36, height: 36, alignment: .center))
    }
}

extension SettingView {
    
    func logOut() {
        fetchMee.isShowUserInfo = false
        fetchMee.loginUserID = "0000" //  设置成一个空的userInfo
        print(#line, self.fetchMee.isShowUserInfo)
        delay(delay: 1, closure: {
            withAnimation {
                
                userDefault.set(false, forKey: "isLoggedIn")
                userDefault.set(nil, forKey: "userIDString")
                userDefault.set(nil, forKey: "screenName")
                userDefault.set(nil, forKey: "mentionUserInfo")
                fetchMee.isLoggedIn = false
            }
        })
    }
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var user: AppData = AppData()
//    static var timeline = Timeline(type: .user)
    static var previews: some View {
        NavigationView {
            SettingView().environmentObject(user)
        }
    }
}
