//
//  ReplyUsersView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/26.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ReplyUsersView: View {
    var replyUsers: [String] = ["jyrnan", "FetchMee"]
    @State var isShowUser: Bool = false
    var body: some View {
        Group {
            () -> AnyView in
            guard !self.replyUsers.isEmpty else {return AnyView(EmptyView())}
            var replyUsersView = Text("Replying to ").foregroundColor(.gray)
            for user in self.replyUsers {
                replyUsersView = replyUsersView
                + Text(" ")
                    + Text(user)
                    .foregroundColor(.blue)
            }
            return AnyView(replyUsersView.font(.body))
        }
        
    }
}

struct ReplyUsersView_Previews: PreviewProvider {
    static var previews: some View {
        ReplyUsersView()
    }
}
