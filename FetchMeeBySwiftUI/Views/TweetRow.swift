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
    @EnvironmentObject var alerts: Alerts
   
    @ObservedObject var timeline: Timeline
    
    var tweetIDString: String
    var tweetMedia: TweetMedia {self.timeline.tweetMedias[tweetIDString] ?? TweetMedia(id: "")}
    @ObservedObject var kGuardian: KeyboardGuardian
    
    @State var presentedUserInfo: Bool = false
    @State var isShowDetail: Bool = false
    var body: some View {
        VStack() {
            HStack(alignment: .top, spacing: 0) {
                VStack {
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
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 0 ) {
                    HStack(alignment: .center) {
                            Text(self.tweetMedia.userName ?? "UserName")
                                .font(.headline)
                                .lineLimit(1)
                            Text("@" + (self.tweetMedia.screenName ?? "screenName"))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            CreatedTimeView(createdTime: self.tweetMedia.created!)
                            Spacer()
                        DetailIndicator(timeline: timeline, tweetIDString: tweetIDString)
                            .padding(.all, 0)
                            .onTapGesture {
                                self.isShowDetail = true
                            }
                   
                    } .sheet(isPresented: self.$isShowDetail) {DetailView(tweetIDString: self.tweetIDString, isShowDetail: self.$isShowDetail).environmentObject(self.alerts)}
                    
                    Text(self.tweetMedia.tweetText ?? "Some tweet text")
                        .font(.body)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .fixedSize(horizontal: false, vertical: true)
                        .onTapGesture {
                            //实现点击出现ToolsVIew快速回复
                            if let prev = self.timeline.tweetIDStringOfRowToolsViewShowed {
                                if prev != tweetIDString {
                                    self.timeline.tweetMedias[prev]?.isToolsViewShowed = false
                                }
                            }
                            withAnimation {
                                self.timeline.tweetMedias[tweetIDString]?.isToolsViewShowed.toggle()
                            }
                            self.timeline.tweetIDStringOfRowToolsViewShowed = tweetIDString
                        }
                    if tweetMedia.images.count != 0 {
                        Images(images: self.tweetMedia.images)
//                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160, alignment: .center)
                            .cornerRadius(16)
                            .clipped()
                    }
//                    ToolsView(timeline: timeline, tweetIDString: tweetIDString)
                }
            }
            
            Spacer()
            if self.timeline.tweetMedias[tweetIDString]!.isToolsViewShowed {
                ToolsView(timeline: timeline, tweetIDString: tweetIDString, someToggle: self.$isShowDetail)
                    .background(GeometryGetter(rect: self.$kGuardian.rects[0]))
            }
            
        }
    }
}


struct TweetRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TweetRow(timeline: Timeline(type: .home), tweetIDString: "", kGuardian: KeyboardGuardian(textFieldCount: 1))
        
    }
}
