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
import KingfisherSwiftUI

struct HubView: View {
    
    @EnvironmentObject var store: Store
    
//    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetDraft.createdAt, ascending: true)]) var logs: FetchedResults<Log>
    
    var tweetText: Binding<String> {$store.appState.setting.checker.tweetText}
    @State var isShowToast: Bool = true
    
    var body: some View {
        GeometryReader{proxy in
            NavigationView {
                
                ScrollView(.vertical, showsIndicators: false){
                    
                    VStack {
                        ComposerOfHubView(tweetText: tweetText)
                            .padding(.top, 16)
                            .padding([.leading, .trailing], 18)
                            .frame(minHeight: 120, idealHeight: 180, maxHeight: 240)
                        
                        Divider()
                        TimelinesView()
                        
                        ToolBarsView(width: proxy.size.width)
                            .padding([.leading, .trailing], 16)
                        
                        Text("Developed by @jyrnan").font(.caption2).foregroundColor(Color.gray)
                        
                        HStack(alignment: .top, spacing: 0 ) {
                            //不得已办法，增加一个固定高度HStack，来撑高外围的VStack，这样让ToolBarsView能够显示全面。
                        }
                        .frame(height: 80)

                        
                    }
                    .background(Color.init("BackGround")).cornerRadius(24)
                    
                }
                .onTapGesture(count: 1, perform: {
                    self.hideKeyboard()
                })
                .navigationTitle("FetchMee")
                .navigationBarItems(trailing: NavigationLink(destination: SettingView(setting: store.appState.setting.loginUser?.setting ?? UserSetting())) {
                                        AvatarImageView(imageUrl:store.appState.setting.loginUser?.avatarUrlString)
                                            .frame(width: 36, height: 36, alignment: .center)})
            }
            .overlay(AlertView()) //所有条状通知在NavigationBar上出现
            .toast(isShowing: $store.appState.setting.isShowImageViewer, presented: store.appState.setting.presentedView)
        }
        
  }
  
}



//MARK:-
extension HubView {
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


