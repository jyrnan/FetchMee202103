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
    
    @StateObject var replySession: Timeline = Timeline(type: .session)
    var tweetIDString: String //传入DetailView的初始推文
    
    @State var firstTimeRun: Bool = true //检测用于运行一次
    
    var body: some View {

                ScrollView {
                    
                    ForEach(replySession.tweetIDStrings, id: \.self) {tweetIDString in
                        
                        TweetRow(viewModel: TweetRowViewModel(timeline: replySession, tweetIDString: tweetIDString, width: 300))
                        Divider()
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading:0, bottom: 0, trailing: 0))
                    Composer(timeline: self.replySession ,tweetIDString: self.tweetIDString).frame(height: 24)
                    Divider()
                    Spacer()
                }
                .navigationTitle("Detail")
                .onAppear {
                    if self.firstTimeRun {
                        self.firstTimeRun = false
                        self.replySession.getReplyDetail(for: self.tweetIDString)
                    } else {print(#line, "firstTimeRun is already true")}} //页面出现时执行一次刷新
                
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(tweetIDString: "")
    }
}
