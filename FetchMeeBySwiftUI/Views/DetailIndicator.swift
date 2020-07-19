//
//  DetailIndicator.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/19.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct DetailIndicator: View {
    @ObservedObject var timeline: Timeline
    var tweetIDString: String
//    var retweetColor: Color = { self.timeline[tweetIDString].retweeted? Color(.red) : Color(.gray) }
    var body: some View {
        HStack(spacing: 0){
            Spacer()
            Circle()
                .fill(self.timeline.tweetMedias[tweetIDString]?.retweeted == true ? Color.blue : Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 3)
            Circle()
                .fill(self.timeline.tweetMedias[tweetIDString]?.favorited == true ? Color.red : Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 3)
            Circle()
                .fill(Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 3)
            Spacer()
        }
        .frame(width: 27, height: 11, alignment: .center)
        .opacity(0.7)
    }
}

struct DetailIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DetailIndicator(timeline: Timeline(type: .home), tweetIDString: "")
    }
}
