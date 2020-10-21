//
//  DetailView.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine


struct DetailView: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    
    @StateObject var replySession: Timeline = Timeline(type: .session)
    var tweetIDString: String //传入DetailView的初始推文
    
    @State var firstTimeRun: Bool = true //检测用于运行一次
    
    var body: some View {
            ZStack{
                ScrollView {
                    
                    ForEach(replySession.tweetIDStrings, id: \.self) {tweetIDString in
                        
                        TweetRow(timeline: replySession, tweetIDString: tweetIDString)
                        Divider()
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading:0, bottom: 0, trailing: 0))
                    Composer(timeline: self.replySession ,tweetIDString: self.tweetIDString).frame(height: 24)
                    Divider()
                    Spacer()
                }
                .onAppear {
                    if self.firstTimeRun {
                        self.firstTimeRun = false
                        self.replySession.getReplyDetail(for: self.tweetIDString)
                    } else {print(#line, "firstTimeRun is already true")}} //页面出现时执行一次刷新
                .navigationTitle("Detail")
                
                AlertView()
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(tweetIDString: "")
    }
}
