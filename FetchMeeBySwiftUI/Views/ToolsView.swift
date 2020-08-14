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
    
    @State var isShowSafari: Bool = false
    @State var url: URL = URL(string: "https://www.twitter.com")!
    
    @State var isAlertShowed: Bool = false
    
    var body: some View {
        VStack {
            HStack{
                
                Image(systemName: "xmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18, alignment: .center)
                    .onTapGesture {
                        
                        swifter.destroyTweet(forID: tweetIDString,
                                             success: { _ in
                                                if let index = self.timeline.tweetIDStrings.firstIndex(of: tweetIDString) {
                                                    withAnimation {self.timeline.tweetIDStrings.remove(at: index)} } },
                                             failure: {_ in
                                                self.isAlertShowed = true
                                             })
                    }
                    .alert(isPresented: self.$isAlertShowed, content: {
                        Alert(title: Text("You can't delete this tweet"))
                    })
           
            Spacer()
            
            Image(systemName: self.timeline.tweetMedias[tweetIDString]!.retweeted == false ? "repeat" : "repeat.1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18, alignment: .center)
                .foregroundColor(self.timeline.tweetMedias[tweetIDString]?.retweeted == true ? Color.green : Color.gray)
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
            
            if self.timeline.tweetMedias[tweetIDString]?.retweet_count != 0 {
                Text(String(self.timeline.tweetMedias[tweetIDString]?.retweet_count ?? 0)).font(.subheadline) }
            Spacer()
            
            Image(systemName: (self.timeline.tweetMedias[tweetIDString]!.favorited == false ? "heart" : "heart.fill"))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18, alignment: .center)
                .foregroundColor(self.timeline.tweetMedias[tweetIDString]?.favorited == true ? Color.red : Color.gray)
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
            if self.timeline.tweetMedias[tweetIDString]?.favorite_count != 0 {
                Text(String(self.timeline.tweetMedias[tweetIDString]?.favorite_count ?? 0)).font(.subheadline) }
            Spacer()
            
            Image(systemName: "square.and.arrow.up")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18, alignment: .center)
                .onTapGesture {
                    if let screenName = self.timeline.tweetMedias[tweetIDString]?.screenName {
                        self.url = URL(string: "https://twitter.com/\(screenName)/status/\(tweetIDString)")!
                    }
                    print(#line, self.url)
                    self.isShowSafari = true
                }
                .sheet(isPresented: self.$isShowSafari, content: {
                    SafariView(url: self.$url)
                })
            
        }.foregroundColor(.gray).padding([.leading, .trailing], 16)
        
        //            Divider()
        Composer(timeline: self.timeline, tweetIDString: self.tweetIDString)
            .padding(.top, 4)
            .padding(.bottom, 4)
            .frame(height: 24)
            .padding(8)
            .background(Color.accentColor.opacity(0.8))
            .overlay(TopShadow(), alignment: .top)
            .overlay(BottomShadow(), alignment: .bottom)
        //            content: Gradient(colors: [.black, .clear])
    }
    //        .padding(16)
    .font(.body)
    
}
}

struct ToolsView_Previews: PreviewProvider {
    static var previews: some View {
        ToolsView(timeline: Timeline(type: .home), tweetIDString: "")
            .preferredColorScheme(.light)
    }
}

struct TopShadow: View {
    var body: some View {
        Rectangle().fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .top, endPoint: .bottom))
            .frame(height: 5).opacity(0.4)
    }
}

struct BottomShadow: View {
    var body: some View {
        Rectangle().fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint:.bottom , endPoint: .top))
            .frame(height: 3).opacity(0.4)
    }
}
