//
//  SettingView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/8/8.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import CoreData
import Kingfisher

struct SettingView: View {
    @EnvironmentObject var store: Store
    @Environment(\.presentationMode) var presentationMode
    var isLogined: Bool {store.appState.setting.loginUser?.tokenKey != nil}
    
    //用来作为setting调整结果的零时存储
    @State var setting: UserSetting
    //显示确认退出alertView
    @State var isPresentedAlert: Bool = false
    
    
    
    var body: some View {
        
        Form {

            Section(header: Text("Visual"),
                    footer: Text("You can swith this function off to get a simper UI and better performance")) {

                Picker("Favorit Theme Color", selection: $setting.themeColor, content: {
                    ForEach(ThemeColor.allCases){themeColor in
                        Text(themeColor.rawValue.capitalized).foregroundColor(themeColor.color).tag(themeColor)
                    }
                })

                Picker("Favorit UIStyle", selection: $setting.uiStyle, content: {
                    ForEach(UIStyle.allCases){style in
                        Text(style.rawValue.capitalized).tag(style)
                    }
                })


                Toggle("Auto Fetch More", isOn: self.$setting.isAutoFetchMoreTweet)
            }

            Section(header:Text("Other")){

                NavigationLink(destination: UserMarkManageView(),
                               label: {Label(title: {Text("Favorite User")},
                                             icon:{Image(systemName: "star.circle.fill").foregroundColor(.accentColor)})})
                
                NavigationLink(destination: CountView(),
                               label: {Label(title: {Text("Login User Infomation")},
                                             icon:{Image(systemName: "info.circle.fill")
                                                .foregroundColor(.accentColor)
                                             })})
                
                NavigationLink(destination: TweetTagCDManageView(),
                               label: {Label(title: {Text("Tweet Tags")},
                                             icon:{Image(systemName: "number.circle.fill")
                                                .foregroundColor(.accentColor)
                                             })})

                
                NavigationLink(destination: BookmarkedStatusView(),
                               label: {Label(title: {Text("Bookmarked Tweets")},
                                             icon:{Image(systemName: "bookmark.circle.fill")
                                                .foregroundColor(.accentColor)
                                             })})
            }

            Section(header:Text("")){
                HStack {
                    Spacer()
                    Button(isLogined ? "Sign Out" : "Sign In"){
                        if isLogined {
                            self.isPresentedAlert = true

                        } else {
                            logOut()
                        }

                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .alert(isPresented: self.$isPresentedAlert) {
                        Alert(title: Text("Sign Out?"), message: nil, primaryButton: .default(Text("Sign Out"), action: {self.logOut()}), secondaryButton: .cancel())}
                    Spacer()
                }.listRowBackground(Color.accentColor)
                HStack {
                    Spacer()
                    Text("FetchMee Developed by @jyrnan").font(.caption).foregroundColor(.gray)
                    Spacer()
                }
            }
        }
        
        .onDisappear{store.dipatch(.changeSetting(setting: setting))}
        .navigationTitle("Setting")

    }
}

extension SettingView {
    
    func logOut() {
        presentationMode.wrappedValue.dismiss()
        
        delay(delay: 1, closure: {
            withAnimation {
                store.dipatch(.updateLoginAccount(loginUser: nil))
            }
        })
    }
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingView(setting: UserSetting())
        }
    }
}

