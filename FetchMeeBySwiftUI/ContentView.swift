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
    @ObservedObject var home = Timeline(type: TweetListType.home)
    @ObservedObject var mentions = Timeline(type: TweetListType.mention)
    
    @State var tweetText: String = ""
    
    @State var isFirstRun: Bool = true //设置用于第一次运行刷新的时候标志
  
    var body: some View {
        NavigationView{
                List {
                    HStack {
                        TextField("Tweet something", text: $tweetText)
                        Button(self.tweetText == "" ? "Refresh" : "Tweet" ) {
                            if self.tweetText != "" {
                                self.home.swifter.postTweet(status: self.tweetText)
                                self.tweetText = ""
                            } else {
                                self.refreshAll()
                            }
                            
                        }
                    }
                    
                    
                    Section(header: Text("Mentions").font(.headline)){
                        
                        TweetsList(timeline: self.mentions, tweetListType: TweetListType.mention)
                        HStack {
                                    Spacer()
                            Button("Refresh Tweets...") {
                                self.mentions.refreshFromButtom()}
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                    }
                    .listRowInsets(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
                    Section(header: Text("Homeline").font(.headline)){
                        TweetsList(timeline: self.home, tweetListType: TweetListType.home)
                        HStack {
                                    Spacer()
                            Button("Refresh Tweets...") {
                                
                                self.home.refreshFromButtom()}
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                    }
                }
                .onAppear {
                    if self.isFirstRun {
                        self.clearRefreshAll()
                        isFirstRun = false
                    }
                }
                .navigationTitle("FetchMee")
                .navigationBarItems(trailing: Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 32, height: 32, alignment: .center)
                                        .onTapGesture {
                                            print(#line)
                                        })
                
        }
    }
    
    func refreshAll() {
        self.home.refreshFromTop()
        self.mentions.refreshFromTop()
    }
    
    func clearRefreshAll() {
        self.home.refreshFromTop(isClearRefresh: true)
        self.mentions.refreshFromTop(isClearRefresh: true)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
