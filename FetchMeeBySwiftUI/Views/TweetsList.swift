//
//  Homeline.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

enum TweetListType: String {
    case home = "Home"
    case mention = "Mentions"
    case list
    case user
}

struct TweetsList: View {
    @State var tweetListType: TweetListType
    @ObservedObject var timeline = Timeline()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                   
                    ForEach(self.timeline.tweetIdStrings, id: \.self) {
                        
                        tweetIDString in
                        
                        NavigationLink(destination: DetailView()) {
                             TweetRow(tweetMedia: self.timeline.tweetMedias[tweetIDString]!)
                        }
                       
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
            .navigationBarTitle(self.tweetListType.rawValue)
        .navigationBarItems(trailing: Button(
            "Refesh", action: {
                self.timeline.getJSON(type: self.tweetListType)
        }))
        }
    .onAppear(perform: {
//        self.timeline.getJSON(type: self.tweetListType)
    })
    }
}

struct TweetsList_Previews: PreviewProvider {
    static var previews: some View {
        TweetsList(tweetListType: TweetListType.home)
    }
}
