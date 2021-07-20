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
    
    @EnvironmentObject var store: Store
    @State var isShowToast: Bool = true
    var tweetText: Binding<String>
    
    var body: some View {
        GeometryReader{proxy in
            NavigationView {
                
                ScrollView(.vertical, showsIndicators: false){
                    
                    VStack {
                        ComposerOfHubView(swifter: store.fetcher.swifter, tweetText: tweetText)
                            .padding(.horizontal, 16).padding(.top, 16)
                            .frame(minHeight: 180, idealHeight: 240, maxHeight: 240)
                        
                        Divider()
                        
                        TimelinesView().padding(0)
                        
                        ToolBarsView(user: store.appState.setting.loginUser ?? User())
                            .padding(.horizontal, 16)
                        StatusView(width: proxy.size.width)
                            .padding(.horizontal, 16)
                        AuthorView
                        
                    }
                    
                    .background(Color.init("BackGround")).cornerRadius(24)
                    
                }
                
                .onTapGesture(count: 1, perform: {
                    self.hideKeyboard()
                })
                
                .navigationTitle("FetchMee")
                .navigationBarItems(trailing: NavigationLink(destination: SettingView(setting: store.appState.setting.userSetting ?? UserSetting())) {
                                        AvatarImageView(imageUrl:store.appState.setting.loginUser?.avatarUrlString ?? "")
                                            .frame(width: 36, height: 36, alignment: .center)})
            }
            .overlay(AlertView()) //所有条状通知在NavigationBar上出现
        }
  }
    
    private var AuthorView: some View {
        Text("Developed by @jyrnan")
            .font(.caption2)
            .foregroundColor(Color.secondary)
            .padding()
    }
}



//MARK:-
extension HubView {
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct HubView_Previews: PreviewProvider {
    static var previews: some View {
        HubView(tweetText: .constant(""))
            .environmentObject(Store.sample)
    }
}
