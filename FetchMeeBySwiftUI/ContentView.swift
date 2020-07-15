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
    
    @ObservedObject var user: User
    
    @State var tweetText: String = ""
    
    @State var isFirstRun: Bool = true //设置用于第一次运行刷新的时候标志
    
    @State var isHiddenMention: Bool = false
  
    var body: some View {
        NavigationView{
            if #available(iOS 14.0, *) {
                List {
                    HStack {
                        TextField("Tweet something", text: $tweetText)
                        Button(self.tweetText == "" ? "Refresh" : "Tweet" ) {
                            if self.tweetText != "" {
                                swifter.postTweet(status: self.tweetText)
                                self.tweetText = ""
                            } else {
                                self.refreshAll()
                            }
                            
                        }
                    }
                    
                    
                    Section(header: Button(action: { self.isHiddenMention.toggle() },
                                           label: {Text("Mentions").font(.headline)})){
                        if !isHiddenMention {
                            TweetsList(timeline: self.mentions, tweetListType: TweetListType.mention)
                        }
                        HStack {
                            Spacer()
                            Button("More Tweets...") {
                                self.mentions.refreshFromButtom()}
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                    
                    
                    Section(header: Text("Homeline").font(.headline)){
                        TweetsList(timeline: self.home, tweetListType: TweetListType.home)
                        HStack {
                            Spacer()
                            Button("More Tweets...") {
                                
                                self.home.refreshFromButtom()}
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .onAppear {
                    if self.isFirstRun {
                        self.refreshAll()
//                        self.user.getMyInfo()
                        isFirstRun = false
                    }
                }
                .navigationTitle("FetchMee")
                .navigationBarItems(trailing: Image(uiImage: (self.user.myInfo.avatar ?? UIImage(systemName: "person.circle.fill")!))
                                        .resizable()
                                        .frame(width: 32, height: 32, alignment: .center)
                                        .clipShape(Circle())
                                        .onLongPressGesture {
                                            self.logOut()
                                        })
            } else {
                // Fallback on earlier versions
            }
                
        }
    }
    
    
       
}

extension ContentView {
    
    func refreshAll() {
        self.home.refreshFromTop()
        self.mentions.refreshFromTop()
        self.user.getMyInfo()
        
    }
    
    func logOut() {
        self.user.isLoggedIn = false
        print(#line)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(user: User())
    }
}
