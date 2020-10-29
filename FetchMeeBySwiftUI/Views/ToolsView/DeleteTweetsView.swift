//
//  DeleteTweetsView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/8/17.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

//struct DeleteTweetsView: View {
//    @EnvironmentObject var user: AppData
//    @ObservedObject var timeline: Timeline
//    
//    var body: some View {
//        List {
//            ForEach(self.timeline.tweetIDStrings, id: \.self) {
//                tweetIDString in
//                TweetRow(timeline: self.timeline, tweetIDString: tweetIDString)
//            }.onDelete(perform: {IndexSet in
//                print(#line)
//            })
//            HStack {
//                Spacer()
//                Button("More Tweets...") {
//                    self.timeline.refreshFromButtom(for: self.user.myInfo.id)}
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                Spacer()
//            } //下方载入更多按钮
//        }
//        .navigationBarTitle(self.user.myInfo.name ?? "Name", displayMode: .inline)
//        .navigationBarItems(trailing: EditButton())
//    }
//}
//
//struct DeleteTweetsView_Previews: PreviewProvider {
//    static var user = AppData()
//    static var userTimeline = Timeline(type: .user)
//    static var previews: some View {
//        DeleteTweetsView( timeline: Self.userTimeline).environmentObject(user)
//    }
//}
