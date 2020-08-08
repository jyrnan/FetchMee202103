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
            Section(header: Text("Visual")) {
                
                Picker(selection: self.$user.myInfo.setting.themeColorValue, label: Text("Theme Color"), content: {
                    Text("0").tag(0)
                    Text("1").tag(1)
                }).pickerStyle(SegmentedPickerStyle())
                HStack {
                    
                    Spacer()
                    Toggle("Iron Fans Rate:", isOn: self.$user.myInfo.setting.isIronFansShowed)
                }
                Spacer()
                HStack {
                    Spacer()
                    Button("Login out"){
                            self.isPresentedAlert = true
                        }
//                    .foregroundColor(.primary)
                    .listRowBackground(Color.accentColor)
                        .alert(isPresented: self.$isPresentedAlert) {
                            Alert(title: Text("Login Out?"), message: nil, primaryButton: .default(Text("Logout"), action: {self.logOut()}), secondaryButton: .cancel())}
                    Spacer()
                }
                
            }
        }
    }
    func logOut() {
        self.user.isLoggedIn = false
        userDefault.set(false, forKey: "isLoggedIn")
        userDefault.set(nil, forKey: "userIDString")
        userDefault.set(nil, forKey: "screenName")
        userDefault.set(nil, forKey: "mentionUserInfo")
        print(#line)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
