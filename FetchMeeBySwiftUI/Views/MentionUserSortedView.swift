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
    
    @ObservedObject var mentions: Timeline
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(mentions.mentionUserIDStringsSorted, id: \.self) {userIDString in
                    AvatarView(avatar: (mentions.userInfos[userIDString]?.avatar)!, userIDString: userIDString)
                        .frame(width: 24, height: 24)
                }
            }
          
        }
       
    }
}

struct MentionUserSortedView_Previews: PreviewProvider {
    static var previews: some View {
        MentionUserSortedView(mentions: Timeline(type: .mention))
    }
}
