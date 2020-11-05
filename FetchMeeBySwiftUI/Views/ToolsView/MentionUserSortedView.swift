//
//  MentionUserSortedView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/31.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

struct MentionUserSortedView: View {
    
    @StateObject var mentionUsers = MentionUser()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ///选取最多10个用户显示
                ForEach(mentionUsers.mentionUserIDStringsSorted[0..<min(10, self.mentionUsers.mentionUserIDStringsSorted.count)], id: \.self) {userIDString in
                    AvatarView(avatar: mentionUsers.userInfos[userIDString]?.avatar, userIDString: userIDString)
                        .frame(width: 32, height: 32)
                }
            }
        }
    }
}

struct MentionUserSortedView_Previews: PreviewProvider {
    static var previews: some View {
        MentionUserSortedView(mentionUsers: MentionUser())
    }
}
