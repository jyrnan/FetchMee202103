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
import UIKit

struct HubView: View {
    
    
    
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var loginUser: User
    @EnvironmentObject var downloader: Downloader
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetDraft.createdAt, ascending: true)]) var logs: FetchedResults<Log>
    
    @State var tweetText: String = ""
    @State var isShowToast: Bool = true
    
    
    init() {
        setNavigationBar()
    }
    
    var body: some View {
        
        NavigationView {
            
            ScrollView(.vertical, showsIndicators: false){
                
                ZStack{
                    VStack {
//                        PullToRefreshView(action: {self.refreshAll()}, isDone: .constant(true)) {
                            ComposerOfHubView(tweetText: $tweetText)
                                .padding(.top, 16)
                                .padding([.leading, .trailing], 18)
//                        }
                        .frame(minHeight: 120, idealHeight: UIScreen.main.bounds.height - 600, maxHeight: .infinity)
                        
                        Divider()
                        TimelinesView()
                        
                        ToolBarsView()
                            .padding([.leading, .trailing], 16)
                        
                        HStack {
                            Text(alerts.logMessage.alertText == "" ? "No new log message" : alerts.logMessage.alertText)
                                .font(.caption2).foregroundColor(.gray).opacity(0.5)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            Button(action: {}){Text("Developed by @jyrnan").font(.caption2).foregroundColor(Color.gray)}
                            Spacer()
                        }.padding(.top, 20).padding()
                        
                    }
                    
                    AlertView()
                }.background(Color.init("BackGround")).cornerRadius(24)
                
            }
            .onTapGesture(count: 1, perform: {
                self.hideKeyboard()
            })
            .navigationTitle("FetchMee")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: NavigationLink(destination: SettingView()) {
                                    AvatarImageView(image: loginUser.info.avatar).frame(width: 36, height: 36, alignment: .center)})
        }
        .toast(isShowing: $alerts.isShowingPicture, presented: alerts.presentedView)
        
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
        loginUser.getUserInfo()
        self.alerts.setLogInfo(text:  "Started fetching new tweets...")
        
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    fileprivate func setNavigationBar() {
        let transAppearance = UINavigationBarAppearance()
        transAppearance.configureWithOpaqueBackground()
        //        transAppearance.backgroundColor = UIColor.clear
        transAppearance.backgroundImage = UIImage(named: "Logo")?.alpha(0.05)
        transAppearance.backgroundImageContentMode = .bottomRight
        transAppearance.shadowColor = .clear
        
        //        UINavigationBar.appearance().standardAppearance = transAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = transAppearance
    }
    
}


