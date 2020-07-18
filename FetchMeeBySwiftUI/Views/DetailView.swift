//
//  DetailView.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI


struct DetailView: View {
    @ObservedObject var sessionTimeline: Timeline = Timeline(type: .session)
    var tweetIDString: String
    var firstTimeRun: Bool?
    
    var body: some View {
        
        if #available(iOS 14.0, *) {
            List {
                if !sessionTimeline.isDone {
                    HStack {
                        Spacer()
                        ActivityIndicator(isAnimating: self.$sessionTimeline.isDone, style: .medium)
                        
                        Spacer()
                    }
                }
                Button(action: {self.sessionTimeline.getReplyDetail(for: self.tweetIDString)}, label: {
                    /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
                })
                ForEach(sessionTimeline.tweetIDStrings, id: \.self) {tweetIDString in
                    TweetRow(timeline: sessionTimeline, tweetIDString: tweetIDString)
                }
                ToolsView(timeline: self.sessionTimeline, tweetIDString: self.tweetIDString)
            }
            .listStyle(InsetGroupedListStyle())
        } else {
            // Fallback on earlier versions
        }
//            .onAppear {
//                if self.firstTimeRun == nil {
//                    self.firstTimeRun = false
//                    self.sessionTimeline.getReplyDetail(for: self.tweetIDString)
//                    print(#line, "onAppear")
//                    }}
                }
                
            }
    


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(tweetIDString: "")
    }
}
