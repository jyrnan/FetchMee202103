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
    @ObservedObject var timeline: Timeline
    var tweetIDString: String
    var tweetMedia: TweetMedia {self.timeline.tweetMedias[tweetIDString] ?? TweetMedia(id: "")}
    
    @State var presentedUserInfo: Bool = false
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 0) {
                Image(uiImage: self.tweetMedia.avatar!)
                    .resizable()
                    .frame(width: 36, height: 36)
                    
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    
                    .padding(.init(top: 4, leading: 0, bottom: 4, trailing: 12))
                    
                    .onTapGesture {
                        self.presentedUserInfo = true
                    }
                    .sheet(isPresented: $presentedUserInfo) {
                        UserInfo()
                    }
                
                Text(self.removeReplier(from: self.tweetMedia.tweetText) )
                    .lineLimit(2)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                CreatedTimeView(createdTime: self.tweetMedia.created!)
            }
            .onTapGesture {
                //实现点击出现ToolsVIew快速回复
                if let prev = self.timeline.tweetIDStringOfRowToolsViewShowed {
                    if prev != tweetIDString {
                        self.timeline.tweetMedias[prev]?.isToolsViewShowed = false
                    }
                }
                withAnimation{
                    self.timeline.tweetMedias[tweetIDString]?.isToolsViewShowed.toggle()
                }
                self.timeline.tweetIDStringOfRowToolsViewShowed = tweetIDString
            }
            Spacer()
            if self.timeline.tweetMedias[tweetIDString]!.isToolsViewShowed {
                ToolsView(timeline: timeline, tweetIDString: tweetIDString)
            }
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
