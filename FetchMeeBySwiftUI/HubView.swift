//
//  HubView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/10.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import BackgroundTasks
import Swifter
import CoreData

struct HubView: View {
    
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    @EnvironmentObject var downloader: Downloader
   
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetDraft.createdAt, ascending: true)]) var logs: FetchedResults<Log>
    
    @State var tweetText: String = ""
    
    var body: some View {
        
        NavigationView {
            GeometryReader {geometry in
            ZStack{
                LogoBackground()
                ScrollView(.vertical, showsIndicators: false){
                    
                    ZStack{
                        VStack {
                            PullToRefreshView(action: {self.refreshAll()}, isDone: $user.home.isDone) {
                                ComposerOfHubView(tweetText: $tweetText)
                                    .padding(.top, 16)
                                    .padding([.leading, .trailing], 18)
                            }
                            .frame(height: geometry.size.height - 428 > 0 ? geometry.size.height - 428 : 180)
                            
                            Divider()
                            TimelinesView()
                            
                            ToolBarsView()
                                .padding([.leading, .trailing], 16)
                            
                            HStack {
                                NavigationLink(destination: LogMessageView()){
                                    Text(alerts.logInfo.alertText == "" ? "No new log message" : alerts.logInfo.alertText)
                                    .font(.caption2).foregroundColor(.gray).opacity(0.5)
                            }
                            }
                            
                            Spacer()
                            
                            HStack {
                                Spacer()
                                Button(action: {}){Text("Developed by @jyrnan").font(.caption2).foregroundColor(Color.gray)}
                                    
                                Spacer()
                            }.padding(.top, 20).padding()
                            
                        }
                        
                        AlertView()
                    }
                   
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .onTapGesture(count: 1, perform: {self.hideKeyboard()})
            .navigationTitle("FetchMee")
            .navigationBarItems(trailing: NavigationLink(destination: SettingView()) {
                AvatarImageView(image: user.myInfo.avatar).frame(width: 36, height: 36, alignment: .center)})
            }
        }
    }
}

struct HubView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            HubView().environmentObject(User())
            HubView().environmentObject(User()).environment(\.colorScheme, .dark)
        }
    }
}

//MARK:-设置后台刷新的内容
extension HubView {
    
    func refreshAll() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred() //产生震动提示
        user.home.refreshFromTop(completeHandeler: {
            self.alerts.setLogInfo(text:  "Fetching ended.")
            
        })
        user.mention.refreshFromTop()
        user.getMyInfo()
        self.alerts.setLogInfo(text:  "Started fetching new tweets...")

    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

