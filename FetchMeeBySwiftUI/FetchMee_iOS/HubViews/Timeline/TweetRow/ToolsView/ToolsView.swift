//
//  ToolsView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/16.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ToolsView: View {
    var tweetIDString: String {viewModel.status["id_str"].string ?? "0000"}
    
    @ObservedObject var viewModel: ToolsViewModel
    
    @State var isShowSafari: Bool = false
    @State var url: URL = URL(string: "https://www.twitter.com")!
    
    @State var isAlertShowed: Bool = false
    
    init(viewModel: ToolsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            HStack{
                
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18, alignment: .center)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        swifter.destroyTweet(forID: tweetIDString,
                                             success: { _ in
                                                if let index = viewModel.timeline.tweetIDStrings.firstIndex(of: tweetIDString) {
                                                    viewModel.timeline.tweetIDStrings.remove(at: index + 1)
                                                    viewModel.timeline.tweetIDStrings.remove(at: index)
                                                    viewModel.timeline.tweetIDStringOfRowToolsViewShowed = nil
                                                } },
                                             failure: {_ in
                                                self.isAlertShowed = true
                                             })
                    }
                    .alert(isPresented: self.$isAlertShowed, content: {
                        Alert(title: Text("You can't delete this tweet"))
                    })
           
            Spacer()
            
                Image(systemName: viewModel.retweeted ? "repeat.1" : "repeat")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18, alignment: .center)
                .foregroundColor(viewModel.retweeted == true ? Color.green : Color.gray)
                .onTapGesture {viewModel.retweet()}
            
            if viewModel.retweetedCount != 0 {
                Text(String(viewModel.retweetedCount)).font(.subheadline) }
            Spacer()
            
                Image(systemName: viewModel.favorited ? "heart.fill" : "heart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18, alignment: .center)
                .foregroundColor(viewModel.favorited ? Color.red : Color.gray)
                .onTapGesture {viewModel.favorite()}
                
                if viewModel.favoritedCount != 0 {
                Text(String(viewModel.favoritedCount)).font(.subheadline) }
            Spacer()
            
            Image(systemName: "square.and.arrow.up")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18, alignment: .center)
                .onTapGesture {
                    if let screenName = viewModel.status["screen_name"].string {
                        self.url = URL(string: "https://twitter.com/\(screenName)/status/\(tweetIDString)")!
                    }
                    print(#line, self.url)
                    self.isShowSafari = true
                }
                .sheet(isPresented: self.$isShowSafari, content: {
                    SafariView(url: self.$url)
                })
            
            }.foregroundColor(.gray).padding(.horizontal, 16).padding(.top, 4)
        
            Composer(isProcessingDone: $viewModel.timeline.isDone, tweetIDString: self.tweetIDString)
            .padding(.top, 4)
            .padding(.bottom, 4)
                .padding(.horizontal, 16)
            .frame(height: 42)
            .background(Color.accentColor.opacity(0.4))
            .overlay(TopShadow(), alignment: .top)
            .overlay(BottomShadow(), alignment: .bottom)
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
