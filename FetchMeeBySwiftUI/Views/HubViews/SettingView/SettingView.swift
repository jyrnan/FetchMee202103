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

struct SettingView: View {
    @EnvironmentObject var store: Store
//    @Environment(\.presentationMode) var presentationMode
    
    //用来作为setting调整结果的临时存储
    @State var setting: UserSetting
    
    //显示确认退出alertView
    @State var isPresentedAlert: Bool = false
    @State private var isShowSaveButton: Bool = false
    
    
    
    //MARK: - View Properties
    
    fileprivate var themeColorPicker: some View {
        return Picker("Favorit Theme Color", selection: $setting.themeColor, content: {
            ForEach(ThemeColor.allCases){themeColor in
                Text(themeColor.rawValue.capitalized)
                    .foregroundColor(themeColor.color)
                    .tag(themeColor)
            }
        })
            .pickerStyle(.segmented)
    }
    
    fileprivate var rowStylePicker: some View {
        return Picker("Favorit UIStyle", selection: $setting.uiStyle, content: {
            ForEach(UIStyle.allCases){style in
                Text(style.rawValue.capitalized)
                    .tag(style)
            }
        })
            .pickerStyle(.segmented)
    }
    
    var body: some View {
        
        List {
            Section(header: Text("Visual"),
                    footer: Text("You can switch this function off to get a simper UI and better performance")) {
                
                themeColorPicker
                rowStylePicker
                Toggle("Auto Fetch More", isOn: self.$setting.isAutoFetchMoreTweet)
            }
            
            Section(header:Text("Other")){
                
                NavigationLink(destination: UserMarkManageView(),
                               label: {Label(title: {Text("Favorite User")},
                                             icon:{Image(systemName: "star.circle.fill")
                                   .foregroundColor(.accentColor)
                               })})
                
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
                    Button("Sign Out"){self.isPresentedAlert = true}
                    .font(.headline)
                    .foregroundColor(.white)
                    .alert(isPresented: self.$isPresentedAlert) {
                        Alert(title: Text("Sign Out?"), message: nil, primaryButton: .default(Text("Sign Out"), action: {self.logOut()}), secondaryButton: .cancel())}
                    Spacer()
                }
                .listRowBackground(Color.accentColor)
                
                HStack {
                    Spacer()
                    Text("FetchMee Developed by @jyrnan").font(.caption).foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .navigationTitle("Setting")
        .navigationBarItems(trailing: Button("Save") {
                    store.dispatch(.changeSetting(setting: setting))
                }
                .disabled(!isShowSaveButton)
        )
        .onChange(of: setting, perform: {_ in
            isShowSaveButton = true
        })
        
    }
}

extension SettingView {
    
    func logOut() {
        delay(delay: 1, closure: {
            withAnimation {
                store.dispatch(.updateLoginAccount(loginUser: nil))
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

