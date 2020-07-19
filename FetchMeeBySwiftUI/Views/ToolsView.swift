//
//  ToolsView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/16.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ToolsView: View {
    @ObservedObject var timeline: Timeline
    var tweetIDString: String
    
    var body: some View {
        VStack {
            HStack{
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "bubble.right")
                })
                Spacer()
                Button(action: {
                    if self.timeline.tweetMedias[tweetIDString] != nil {
                        switch self.timeline.tweetMedias[tweetIDString]!.retweeted {
                        case true:
                            swifter.unretweetTweet(forID: tweetIDString)
                            self.timeline.tweetMedias[tweetIDString]?.retweeted = false
                        case false:
                            swifter.retweetTweet(forID: tweetIDString)
                            self.timeline.tweetMedias[tweetIDString]?.retweeted = true
                        }
                    }
                }, label: {
                    Image(systemName: self.timeline.tweetMedias[tweetIDString]!.retweeted == false ? "repeat" : "repeat.1")
                })
                Spacer()
                Button(action: {
                    if self.timeline.tweetMedias[tweetIDString] != nil {
                        switch self.timeline.tweetMedias[tweetIDString]!.favorited {
                        case true:
                            swifter.unfavoriteTweet(forID: tweetIDString)
                            self.timeline.tweetMedias[tweetIDString]?.favorited = false
                        case false:
                            swifter.favoriteTweet(forID: tweetIDString)
                            self.timeline.tweetMedias[tweetIDString]?.favorited = true
                        }
                    }
                }, label: {
                    Image(systemName: (self.timeline.tweetMedias[tweetIDString]!.favorited == false ? "heart" : "heart.fill"))
                })
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "square.and.arrow.up")
                        
                })
            }.accentColor(.gray)
            .padding(.bottom, 10)
//            Divider()
//            Composer(timeline: timeline, tweetIDString: tweetIDString)
//                .padding(.top, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
//                .padding(.bottom, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            
        }

    }
}

struct ToolsView_Previews: PreviewProvider {
    static var previews: some View {
        ToolsView(timeline: Timeline(type: .home), tweetIDString: "")
            .preferredColorScheme(.light)
    }
}
