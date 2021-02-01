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
                
//                ZStack{
                    VStack {
//                        PullToRefreshView(action: {self.refreshAll()}, isDone: .constant(true)) {
                            ComposerOfHubView(tweetText: $tweetText)
                                .padding(.top, 16)
                                .padding([.leading, .trailing], 18)
//                        }
                        .frame(minHeight: 120, idealHeight: UIScreen.main.bounds.height - 600, maxHeight: .infinity)
                        
                        Divider()
                        TimelinesView(lists: loginUser.lists)
                        
                        ToolBarsView()
                            .padding([.leading, .trailing], 16)
                        
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            Button(action: {}){Text("Developed by @jyrnan").font(.caption2).foregroundColor(Color.gray)}
                            Spacer()
                        }.padding(.top, 30).padding()
                        
                    }.background(Color.init("BackGround")).cornerRadius(24)

            }
            .onTapGesture(count: 1, perform: {
                self.hideKeyboard()
            })
            .navigationTitle("FetchMee")
            .navigationBarItems(trailing: NavigationLink(destination: SettingView()) {
                                    AvatarImageView(image: loginUser.info.avatar).frame(width: 36, height: 36, alignment: .center)})
        }
        .overlay(AlertView()) //所有条状通知在NavigationBar上出现
        .toast(isShowing: $alerts.isShowingPicture, presented: alerts.presentedView)
        .overlaySheet(isPresented: $alerts.isShowingOverlaySheet){
           ZStack{
//                RoundedCorners(color: Color.clear, tl: 18, tr: 18, bl: 0, br: 0)
              VStack{
                ComposerOfHubView(
                    tweetText: $tweetText, isUsedAlone: true)
                    .frame(height: 240)
                Spacer()
           }
            }
            
           .blurBackground(style: .systemChromeMaterial)
           .cornerRadius(18)
            .frame(height: 260)
        }
        
    }
    
    fileprivate func setNavigationBar() {
        var themeColor: UIColor { UIColor(ThemeColor(rawValue: (userDefault.object(forKey: "themeColor") as? String) ?? "blue")!.color)}
        let transAppearance = UINavigationBarAppearance()
        transAppearance.configureWithOpaqueBackground()
        //        transAppearance.backgroundColor = UIColor.clear
        transAppearance.backgroundImage = UIImage(named: "Logo")?.alpha(0.05).changeWithColor(color: themeColor)
        transAppearance.backgroundImageContentMode = .bottomRight
        transAppearance.shadowColor = .clear
        
        //        UINavigationBar.appearance().standardAppearance = transAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = transAppearance
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
        self.alerts.setLogMessage(text:  "Started fetching new tweets...")
        
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
   
    
}


