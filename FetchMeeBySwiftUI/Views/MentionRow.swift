//
//  MentionRow.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/14.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

struct MentionRow: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    
    @ObservedObject var timeline: Timeline
    var tweetIDString: String
    var tweetMedia: TweetMedia {self.timeline.tweetMedias[tweetIDString] ?? TweetMedia(id: "")}
    
    @State var presentedUserInfo: Bool = false
    @State var isShowDetail: Bool = false
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 0) {
                AvatarView(avatar: self.tweetMedia.avatar!, userIDString: self.tweetMedia.userIDString)
                    .frame(width: 36, height: 36)
                    .padding(.init(top: 4, leading: 0, bottom: 4, trailing: 12))
                    
                TweetTextView(tweetText: tweetMedia.tweetText )
                    .lineLimit(2)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .onTapGesture {
                        self.isShowDetail = true
                    }
                    .sheet(isPresented: self.$isShowDetail) {DetailView(tweetIDString: self.tweetIDString, isShowDetail: self.$isShowDetail).environmentObject(self.alerts).environmentObject(self.user)}
                Spacer()
                CreatedTimeView(createdTime: self.tweetMedia.created!)
            }
            
//            Spacer()
//            if self.timeline.tweetMedias[tweetIDString]!.isToolsViewShowed {
//                ToolsView(timeline: timeline, tweetIDString: tweetIDString)
//            }
        }
            
    }
}

extension MentionRow {
    func removeReplier(from tweetText: String?) -> String {
        var result: String = ""
        if let tweetTextSplit = tweetText?.split(separator: " ") {
            result = String(tweetTextSplit.last! )
        }
        return result
    }
}


struct MentionRow_Previews: PreviewProvider {
    static var previews: some View {
        MentionRow(timeline: Timeline(type: .home), tweetIDString: "")
    }
}
