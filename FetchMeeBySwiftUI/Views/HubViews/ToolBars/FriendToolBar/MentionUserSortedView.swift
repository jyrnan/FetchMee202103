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
            .map{User(id:$0.id, avatarUrlString: $0.avatarUrlString)}
    }
    
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ///选取最多10个用户显示
                ForEach(mentionUserSorted.prefix(10), id: \.id) {user in
                    AvatarView(width: 32, height: 32, user: user)
                }
            }
        }
    }
}

struct MentionUserSortedView_Previews: PreviewProvider {
    static let store = Store()
    static var previews: some View {
        MentionUserSortedView()
            .environmentObject(store)
    }
}
