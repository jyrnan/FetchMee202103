//
//  ToolsView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/16.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter

struct ToolsView: View {
    @EnvironmentObject var store: Store
    var tweetIDString: String
    
//    @ObservedObject var viewModel: ToolsViewModel
    
    @State var isShowSafari: Bool = false
    @State var url: URL = URL(string: "https://www.twitter.com")!
    
    @State var isAlertShowed: Bool = false
    
    var status: JSON? {StatusRepository.shared.status[tweetIDString]}
    
    var retweeted: Bool { status?["retweeted"].bool ?? false }
    var retweetedCount: Int {status?["retweet_count"].integer ?? 0 }
    
    var favorited: Bool { status?["favorited"].bool ?? false }
    var favoritedCount: Int {status?["favorite_count"].integer ?? 0 }
    
//    init(viewModel: ToolsViewModel) {
//        self.viewModel = viewModel
//    }
    
    var body: some View {
        VStack {
            HStack{
                
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18, alignment: .center)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        store.swifter.destroyTweet(forID: tweetIDString,
                                             success: { _ in
                        },
                                             failure: {_ in
                                                self.isAlertShowed = true
                                             })
                    }
                    .alert(isPresented: self.$isAlertShowed, content: {
                        Alert(title: Text("You can't delete this tweet"))
                    })
           
            Spacer()
            
                Image(systemName: retweeted ? "repeat.1" : "repeat")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18, alignment: .center)
                .foregroundColor(retweeted == true ? Color.green : Color.gray)
                .onTapGesture { }
            
            if retweetedCount != 0 {
                Text(String(retweetedCount)).font(.subheadline) }
            Spacer()
            
                Image(systemName: favorited ? "heart.fill" : "heart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18, alignment: .center)
                .foregroundColor(favorited ? Color.red : Color.gray)
                    .onTapGesture {store.dipatch(.tweetOperation(operation: favorited ? .unfavorite : .favorite, tweetIDString: tweetIDString))
                    }
                
                if favoritedCount != 0 {
                Text(String(favoritedCount)).font(.subheadline) }
            Spacer()
            
            Image(systemName: "square.and.arrow.up")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18, alignment: .center)
                .onTapGesture {
                    if let screenName = status?["screen_name"].string {
                        self.url = URL(string: "https://twitter.com/\(screenName)/status/\(tweetIDString)")!
                    }
                    print(#line, self.url)
                    self.isShowSafari = true
                }
                .sheet(isPresented: self.$isShowSafari, content: {
                    SafariView(url: self.$url)
                })
            
            }.foregroundColor(.gray).padding(.horizontal, 16).padding(.top, 4)
        
            Composer(isProcessingDone: .constant(true), tweetIDString: self.tweetIDString)
            .padding(.top, 4)
            .padding(.bottom, 4)
                .padding(.horizontal, 16)
            .frame(height: 42)
            .background(Color.accentColor.opacity(0.4))

    }
    .font(.body)

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
