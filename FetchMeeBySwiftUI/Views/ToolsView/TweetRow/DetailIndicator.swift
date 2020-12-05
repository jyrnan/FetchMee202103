//
//  DetailIndicator.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/19.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct DetailIndicator: View {
    var timeline = Timeline(type: .home)
     var tweetIDString: String = "0000"
    
//    var retweetColor: Color = { self.timeline[tweetIDString].retweeted? Color(.red) : Color(.gray) }
    var body: some View {
        HStack(spacing: 0){
            Spacer()
            Circle()
                .fill(self.timeline.tweetMedias[tweetIDString]?.retweeted == true ? Color.green : Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 3)
            Circle()
                .fill(self.timeline.tweetMedias[tweetIDString]?.favorited == true ? Color.red : Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 3)
            Circle()
                .fill(self.timeline.tweetMedias[tweetIDString]?.rowIsViewed == true ? Color.gray : Color.accentColor)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 3)
                .onAppear{
                    ///该视图出现则减少新推文数量1，并设置成已经阅读变量标志，避免重复
                    if !(self.timeline.tweetMedias[tweetIDString]?.rowIsViewed ?? true) && (self.timeline.newTweetNumber > 0) {
                        self.timeline.newTweetNumber -= 1
                    }
                    self.delay(delay: 3, closure: {
                        self.timeline.tweetMedias[tweetIDString]?.rowIsViewed = true
                        
                    })
                }
            Spacer()
        }
        .frame(width: 27, height: 11, alignment: .center)
        .opacity(0.7)
        .padding(.all, 0)
        .contentShape(Rectangle())
    }
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

struct DetailIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DetailIndicator(timeline: Timeline(type: .home), tweetIDString: "")
    }
}
