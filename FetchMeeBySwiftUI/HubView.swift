//
//  HubView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/10.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct HubView: View {
    
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    @EnvironmentObject var downloader: Downloader
    
    @StateObject var home = Timeline(type: TweetListType.home)
    @StateObject var mentions = Timeline(type: TweetListType.mention)
    
    
    var body: some View {
        NavigationView {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .navigationTitle("FetchMee")
                .navigationBarItems(trailing:NavigationLink(destination: SettingView()) {
                                                Image(uiImage: (self.user.myInfo.avatar ?? UIImage(systemName: "person.circle.fill")!))
                                                    .resizable()
                                                    .frame(width: 32, height: 32, alignment: .center)
                                                    .clipShape(Circle())
                                                
                                            })
        }
        
    }
}

struct HubView_Previews: PreviewProvider {
    static var previews: some View {
        HubView()
    }
}
