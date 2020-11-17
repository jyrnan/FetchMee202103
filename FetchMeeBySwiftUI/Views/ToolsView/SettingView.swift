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
    @EnvironmentObject var loginUser: User
    @EnvironmentObject var alerts: Alerts
    
    @State var isPresentedAlert: Bool = false //显示确认退出alertView
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Log.createdAt, ascending: true)]) var logs: FetchedResults<Log>
    
    let footerMessage: String = "Switching on Auto Delete tweets will automatically delete them in the background. Due to api restrictions, approximately 80 tweets are deleted per hour. Please keep the application background refresh open. \nIf you need to keep your recent tweets, make sure the Keep Recent switch on. \nPress Delete Tweets Now will immediately delete up to 300 sauces at once. "
    
    let manualDeleteWarningMessage: String = "Selecting Manual Delete will immediately delete up to 300 sauces at once. Due to api limits, the app will automatically calculate the maximum number of tweets that can be deleted and delete them. If you need to keep your recent tweets, make sure the Keep Recent switch is on."
    
    @State var isShowManualDeleteAlert: Bool = false
    
    var body: some View {
        Form {
                Image(uiImage: loginUser.info.banner ?? UIImage(named: "bg")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            .frame(height: 120)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            Section(header: Text("Visual"),
                    footer: Text("You can swith this function off to get a simper UI and better performance")) {
                
                Picker("Favorit Theme Color", selection: self.$loginUser.setting.themeColor, content: {
                    ForEach(ThemeColor.allCases){color in
                        Text(color.rawValue.capitalized).tag(color)
                    }
                })
                
                Toggle("Iron Fans Rate", isOn: self.$loginUser.setting.isIronFansShowed)
                Toggle("Show Pictures", isOn: self.$loginUser.setting.isMediaShowed)
            }
            
            Section(header:Text("Delete Tweets"),
                    footer: Text(footerMessage)){
                
                
                
                Toggle("Auto Delete Tweets", isOn: self.$loginUser.setting.isDeleteTweets)
//                if loginUser.setting.isDeleteTweets {
                    Toggle("Keep Recent 100 Tweets", isOn: self.$loginUser.setting.isKeepRecentTweets)
//            }
                HStack {
                    Spacer()
                    Button(action: {
                        isShowManualDeleteAlert = true
                    }) {
                        Text("Delete Tweets Now")
                    }
                    Spacer()
                }.alert(isPresented: $isShowManualDeleteAlert){
                    Alert(title: Text("Attention"),
                          message: Text(manualDeleteWarningMessage),
                          primaryButton: .destructive(Text("Delete"),
                                                      action: { manualDelete()}),
                          secondaryButton: .cancel())}
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
        .onDisappear{loginUser.setting.save()}
        .navigationTitle("Setting")
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems( trailing: AvatarImageView(image: loginUser.info.avatar).frame(width: 36, height: 36, alignment: .center))
    }
}

extension SettingView {
    
    func logOut() {
//        loginUser.isShowUserInfo = false
        loginUser.info.id = "0000" //  设置成一个空的userInfo
//        print(#line, self.loginUser.isShowUserInfo)
        delay(delay: 1, closure: {
            withAnimation {
                
                userDefault.set(false, forKey: "isLoggedIn")
                userDefault.set(nil, forKey: "userIDString")
                userDefault.set(nil, forKey: "screenName")
                userDefault.set(nil, forKey: "mentionUserInfo")
                loginUser.isLoggedIn = false
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
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
        let completeHandler  = {
            print(#line, #function, "Tweet deleted")
        }
        let lh: (String) -> () = {string in
            self.alerts.setLogMessage(text: string)
        }
        swifter.fastDeleteTweets(for: loginUser.info.id,
                                 keepRecent: loginUser.setting.isKeepRecentTweets,
                                 completeHandler: completeHandler,
                                 logHandler: lh)
    }
}
///
