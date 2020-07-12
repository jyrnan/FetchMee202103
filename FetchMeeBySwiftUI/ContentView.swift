//
//  ContentView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import SwifteriOS
import Combine

struct ContentView: View {
    
    var body: some View {
        TabView {
            TweetsList(tweetListType: .home)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
            }
            
            TweetsList(tweetListType: .mention)
                .tabItem {
                    Image(systemName: "bell")
                    Text("Mentions")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
