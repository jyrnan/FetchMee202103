//
//  ImageGrabView.swift
//  FetchMee
//
//  Created by yoeking on 2020/8/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ImageGrabView: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User //始终是登录用户的信息
    
    var userIDString: String? //传入需查看的用户信息的ID
    var userScreenName: String? //传入需查看的用户信息的Name
    
    @StateObject var checkingUser: User = User()
    @StateObject var userTimeline: Timeline = Timeline(type: .user)
    
    
    var body: some View {
        List {
            ForEach(self.userTimeline.imageTweetStrings, id: \.self) {idString in
                ForEach(self.userTimeline.tweetMedias[idString]?.images.keys, id: \.self) {
                    uiImage in
                    
                }
            }
        }
    }
}

struct ImageGrabView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGrabView()
    }
}
