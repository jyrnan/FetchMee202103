//
//  ReplyUsersView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/26.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ReplyUsersView: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var fetchMee: User
    var replyUsers: [String] = ["jyrnan", "FetchMee"]
    @State var presentedUserInfo: Bool = false
    
    var body: some View {
        Group {
            () -> AnyView in
//            guard !self.replyUsers.isEmpty else {return AnyView(EmptyView())}
            var replyUsersView = Text("Replying to ").foregroundColor(.gray)
            for replyUser in self.replyUsers {
                replyUsersView = replyUsersView
                + Text(" ")
                    + Text(replyUser)
                    .foregroundColor(.accentColor)
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
