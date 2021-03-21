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
    
    var mentionUserIDStringsSorted: [String] {
        let mentionUserInfoSorted = store.appState.timelineData.mentionUserData
            .sorted{$0.count > $1.count}
            .map{$0.id}
        return mentionUserInfoSorted
    }
    
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ///选取最多10个用户显示
                ForEach(mentionUserIDStringsSorted[0..<min(10, mentionUserIDStringsSorted.count)], id: \.self) {userIDString in
                    AvatarView(userIDString: userIDString, width: 32, height: 32)
                }
            }
        }
    }
}

struct MentionUserSortedView_Previews: PreviewProvider {
    static var previews: some View {
        MentionUserSortedView()
    }
}
