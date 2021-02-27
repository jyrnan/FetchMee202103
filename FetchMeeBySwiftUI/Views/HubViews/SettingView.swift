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
import KingfisherSwiftUI

struct SettingView: View {
    
    @EnvironmentObject var alerts: Alerts
    
    @EnvironmentObject var store: Store
    
    ///用来作为setting调整结果的零时存储
    @State var setting: UserSetting = UserSetting()
    
    @State var isPresentedAlert: Bool = false //显示确认退出alertView
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Log.createdAt, ascending: true)]) var logs: FetchedResults<Log>
    
    let footerMessage: String = "Switching on Auto Delete tweets will automatically delete them in the background. Due to api restrictions, approximately 80 tweets are deleted per hour. Please keep the application background refresh open. \nIf you need to keep your recent tweets, make sure the Keep Recent switch on. \nPress Delete Tweets Now will immediately delete up to 300 sauces at once. "
    
    let manualDeleteWarningMessage: String = "Selecting Manual Delete will immediately delete up to 300 sauces at once. Due to api limits, the app will automatically calculate the maximum number of tweets that can be deleted and delete them. If you need to keep your recent tweets, make sure the Keep Recent switch is on."
    
    @State var isShowManualDeleteAlert: Bool = false
    
    var body: some View {
        Form {
            KFImage(URL(string:store.appState.setting.loginUser?.bannerUrlString ?? ""))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            .frame(height: 120)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            Section(header: Text("Visual"),
                    footer: Text("You can swith this function off to get a simper UI and better performance")) {
                
                Picker("Favorit Theme Color", selection: $setting.themeColor, content: {
                    ForEach(ThemeColor.allCases){themeColor in
                        Text(themeColor.rawValue.capitalized).foregroundColor(themeColor.color).tag(themeColor)
                    }
                })
                
                Toggle("Iron Fans Rate", isOn: self.$setting.isIronFansShowed)
                Toggle("Show Pictures", isOn: self.$setting.isMediaShowed)
            }
            
            Section(header:Text("Other")){
                
                NavigationLink(destination: UserMarkManageView(),
                               label: {Label(title: {Text("Favorite User")},
                                             icon:{Image(systemName: "star.circle.fill").foregroundColor(.accentColor)})})
                NavigationLink(destination: LogMessageView(),
                               label: {Label(title: {Text("Log Message")},
                                             icon:{Image(systemName: "envelope.circle.fill").foregroundColor(.accentColor)})})
                NavigationLink(destination: CountView(),
                               label: {Label(title: {Text("Login User Infomation")},
                                             icon:{Image(systemName: "info.circle.fill")
                                                .foregroundColor(.accentColor)
                                             })})
            }
            
            Section(header:Text("")){
//                HStack {
//                    Spacer()
//                    Button("Clear Cache") {
//                        
//                    }
//                    Spacer()
//                }
                
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
        .onDisappear{store.dipatch(.changeSetting(setting: setting))}
        .navigationTitle("Setting")
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems( trailing: AvatarImageView(imageUrl: store.appState.setting.loginUser?.avatarUrlString)
                                .frame(width: 36, height: 36, alignment: .center))
    }
}

extension SettingView {
    
    func logOut() {

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

extension SettingView {
    func deleteAllLogs() {
        logs.forEach{viewContext.delete($0)}
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError.description)
        }
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

extension SettingView {
    fileprivate func manualDelete() {
//        let completeHandler  = {
//            print(#line, #function, "Tweet deleted")
//        }
//        let lh: (String) -> () = {string in
//            self.alerts.setLogMessage(text: string)
//        }
//        swifter.fastDeleteTweets(for: loginUser.info.id,
//                                 keepRecent: loginUser.setting.isKeepRecentTweets,
//                                 completeHandler: completeHandler,
//                                 logHandler: lh)
    }
}
///
