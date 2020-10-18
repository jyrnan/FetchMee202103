//
//  BackOfTweetsToolBar.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/17.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine

struct BackOfTweetsToolBar: View {
    @EnvironmentObject var user: User
    
    var body: some View {
        VStack {
            HStack{
                Toggle(isOn: $user.myInfo.setting.isDeleteTweets) {
                    Text("Delete\nAll")
                        .font(.caption).bold()
                        .foregroundColor(.white)
                }
                .alert(isPresented: $user.myInfo.setting.isDeleteTweets, content: {
                                            Alert(title: Text("Delete Tweets?"), message: Text("Delete ALL choosed, it will delete your tweets in background, are you sure?"), primaryButton: .destructive(Text("Sure"), action: {user.myInfo.setting.isDeleteTweets = true}), secondaryButton: .cancel())})
                
                Divider()
                Toggle(isOn: $user.myInfo.setting.isKeepRecentTweets) {
                    Text("Keep\nRecent").font(.caption).bold()
                        .foregroundColor(.white)
                }
            }
            HStack {
                Spacer()
                Text("\"Keep Recent\" on to reserve last 80 tweets ")
                    .foregroundColor(.white).font(.caption2)
            }
        }.padding([.leading, .trailing]).fixedSize()
    }
}
struct BackOfTweetsToolBar_Previews: PreviewProvider {
    static var previews: some View {
        BackOfTweetsToolBar()
    }
}
