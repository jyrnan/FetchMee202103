//
//  BackOfFriendToolBar.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/17.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine

struct BackOfFriendToolBar: View {
//@EnvironmentObject var fetchMee: User
    var body: some View {
        VStack{
            HStack {MentionUserSortedView()}
            HStack {
                Spacer()
                Text("Those who mentioned you mostly")
                    .foregroundColor(.white).font(.caption2)
            }
        }.padding([.leading, .trailing])
    }
}

struct BackOfFriendToolBar_Previews: PreviewProvider {
    static var previews: some View {
        BackOfFriendToolBar()
    }
}
