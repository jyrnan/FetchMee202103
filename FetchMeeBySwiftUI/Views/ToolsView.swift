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
                
                Image(systemName: "bubble.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18, alignment: .center)
                    .onTapGesture {
                        print()
                    }
                //
                Spacer()
                
                Image(systemName: self.timeline.tweetMedias[tweetIDString]!.retweeted == false ? "repeat" : "repeat.1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18, alignment: .center)
                    .onTapGesture {
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
                    }
                
                Spacer()
                
                Image(systemName: (self.timeline.tweetMedias[tweetIDString]!.favorited == false ? "heart" : "heart.fill"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18, alignment: .center)
                    .onTapGesture {
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
                    }
                
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18, alignment: .center)
                    .onTapGesture {
                        print()
                    }
                
            }.foregroundColor(.gray)
            
            Divider()
            Composer(timeline: self.timeline, tweetIDString: self.tweetIDString)
                .padding(.top, 10)
                .padding(.bottom, 10)
        }
        .font(.body)
    }
}

struct ToolsView_Previews: PreviewProvider {
    static var previews: some View {
        ToolsView(timeline: Timeline(type: .home), tweetIDString: "")
            .preferredColorScheme(.light)
    }
}
