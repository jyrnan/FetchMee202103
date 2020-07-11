//
//  ContentView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import SwifteriOS

struct ContentView: View {
    @ObservedObject var timeline = Timeline()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.timeline.timeline, id: \.self) {
                    tweetIDString in
                    TweetRow(tweetMedia: self.timeline.tweetMedias[tweetIDString]!)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        .navigationBarTitle("Timeline")
        .navigationBarItems(trailing: Button(
            "Refesh", action: {
                self.timeline.getJSON()
        }))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
