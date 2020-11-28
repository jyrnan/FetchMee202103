//
//  TweetRowViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/28.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation

class TweetRowViewModel: ObservableObject{
    @Published var tweetMedia: TweetMedia
    var isToolsViewShowed: Bool {timeline.tweetIDStringOfRowToolsViewShowed == tweetIDString}
    
    let timeline: Timeline
    let tweetIDString: String
    
    init(timeline:Timeline, tweetIDString: String) {
        self.timeline = timeline
        self.tweetIDString = tweetIDString
        
        self.tweetMedia = timeline.tweetMedias[tweetIDString] ?? TweetMedia(id: tweetIDString)
    }
    
    func toggleToolsView() {
        if self.isToolsViewShowed {
            timeline.tweetIDStringOfRowToolsViewShowed = nil
        } else {
            timeline.tweetIDStringOfRowToolsViewShowed = tweetIDString }
    }
}
