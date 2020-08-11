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
    @State var isPresentedAlert: Bool = false
    
    var body: some View {
        List {
            Section(header: Text("Visual"), footer: Text("You can swith this function off to get a simper UI and better performance")) {
                VStack {
                    HStack{
                    Text("Choose your favorist theme color, ").font(.caption).foregroundColor(.gray)
                        Spacer() }
               
                Picker("Color", selection: self.$user.myInfo.setting.themeColor, content: {
                    ForEach(ThemeColor.allCases) {color in
                        Text(color.rawValue.capitalized).tag(color)
                    }
                }).pickerStyle(SegmentedPickerStyle())
                }
                HStack {
                    Toggle("Iron Fans Rate:", isOn: self.$user.myInfo.setting.isIronFansShowed)
                }
            }
            
            Section(header:Text("Other")){
                Text("Place Holder")
                Text("Place Holder")
                Text("Place Holder")
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
        }.listStyle(GroupedListStyle())
        .padding(.top, 16)
        .font(.body)
    }
    func logOut() {
        self.user.isShowUserInfo = false
        print(#line, self.user.isShowUserInfo)
        delay(delay: 1, closure: {
            withAnimation {self.user.isLoggedIn = false
            userDefault.set(false, forKey: "isLoggedIn")
            userDefault.set(nil, forKey: "userIDString")
            userDefault.set(nil, forKey: "screenName")
                userDefault.set(nil, forKey: "mentionUserInfo")}
        })
        
        
    }
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

struct SettingView_Previews: PreviewProvider {
    var user: User = User()
    
    static var previews: some View {
        SettingView()
    }
}
