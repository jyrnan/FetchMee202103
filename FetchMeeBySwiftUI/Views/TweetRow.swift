//
//  TweetRow.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

struct TweetRow: View {
    @ObservedObject var timeline: Timeline
    var tweetIDString: String
    var tweetMedia: TweetMedia {self.timeline.tweetMedias[tweetIDString] ?? TweetMedia(id: "")}
    
    @State var presentedUserInfo: Bool = false
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 0) {
                
                Image(uiImage: self.tweetMedia.avatar!)
                    .resizable()
                    .frame(width: 36, height: 36)
                    
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    
                    .padding(.init(top: 12, leading: 0, bottom: 12, trailing: 12))
                    
                    .onTapGesture {
                        self.presentedUserInfo = true
                    }
                    .sheet(isPresented: $presentedUserInfo) {
                        UserInfo()
                    }
                VStack(alignment: .leading, spacing: 0 ) {
                    HStack {
                        Text(self.tweetMedia.userName ?? "UserName")
                            .font(.headline)
                            .lineLimit(1)
                        Text("@" + (self.tweetMedia.screenName ?? "screenName"))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                        CreatedTimeView(createdTime: self.tweetMedia.created!)
                        Spacer()
                    }
                    Text(self.tweetMedia.tweetText ?? "Some tweet text")
                        .lineLimit(nil)
                        .font(.body)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    Spacer()
                    if tweetMedia.images.count != 0 {
                        Images(images: self.tweetMedia.images)
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                            .clipped()
                            .cornerRadius(16)
                    }
                }
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
                //                        .listRowInsets(.init(top: 0, leading: -16, bottom: 0, trailing: -16))
            } else {
                /*@START_MENU_TOKEN@*/EmptyView()/*@END_MENU_TOKEN@*/
            }
        }
    }
    
}


struct TweetRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TweetRow(timeline: Timeline(type: .home), tweetIDString: "")
        
    }
}
