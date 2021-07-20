//
//  MentionUserSortedView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/31.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import Swifter

struct MentionUserSortedView: View {
    @EnvironmentObject var store: Store
    
    var mentionUserSorted: [User] {
        store.appState.timelineData.mentionUserData
            .sorted{$0.count > $1.count}
            .map{store.appState.timelineData.getUser(byID: $0.id)}
    }
    
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ///选取最多10个用户显示
                ForEach(mentionUserSorted.prefix(10), id: \.id) {user in
                    AvatarView(user: user, width: 32, height: 32)
                }
            }
        }
    }
}

struct MentionUserSortedView_Previews: PreviewProvider {
    static var previews: some View {
        MentionUserSortedView()
            .environmentObject(Store.sample)
    }
}
