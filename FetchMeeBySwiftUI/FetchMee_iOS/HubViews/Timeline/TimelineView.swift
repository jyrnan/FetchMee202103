//
//  ContentView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine
import UIKit


struct TimelineView: View {
   
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var downloader: Downloader
    
    @ObservedObject var timeline: Timeline
    
    @State var tweetText: String = ""
    
    var listName: String? //如果是list类型则会传入listName
    init(timeline: Timeline, listName: String? = nil) {
        self.timeline = timeline
        self.listName = listName
        
    }
    
    var body: some View {
        GeometryReader {proxy in
        ScrollView(.vertical){
           
           
            //Homeline部分章节
            LazyVStack(spacing: 0) {
                RoundedCorners(color: Color.init("BackGround"), tl: 18, tr: 18 ).frame(height: 18)
                
                PullToRefreshView(action: self.refreshAll, isDone: self.$timeline.isDone) {
                        Composer()
                }
                .frame(height: 36)
                .padding(0)
                .background(Color.init("BackGround"))
                
                Rectangle()
                    .frame(height: 18)
                    .foregroundColor(Color.init("BackGround"))
                
                Divider()
                
                ForEach(self.timeline.tweetIDStrings, id: \.self) {tweetIDString in
                    TweetRow(viewModel: timeline.getTweetViewModel(tweetIDString: tweetIDString, width: proxy.size.width))
                    Divider()
                }
                
                HStack {
                    Spacer()
                    Button("More Tweets...") {self.timeline.refreshFromBottom()}
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(height: 24)
                    Spacer()
                }
                .background(Color.init("BackGround")) //下方载入更多按钮
                RoundedCorners(color: Color.init("BackGround"), bl: 18, br: 18 )
                    .frame(height: 18)
            }
            
        }
        .navigationTitle(listName ?? timeline.type.rawValue)
        .onAppear {
//            if timeline.tweetIDStrings.isEmpty {
//                timeline.refreshFromTop()
//            }

            //出现后重置新推文数量
//            if timeline.newTweetNumber != 0 {
//                timeline.newTweetNumber = 0
//            }
        }
        }
        
    }
}

extension TimelineView {
    /**
     处理出错的handler，可以传入到timeline里面执行。
     */
    func failureHandler(error: Error) -> Void {
        print(#line, error.localizedDescription)
        self.alerts.stripAlert.alertText = "Sorry! Network error!"
        self.alerts.stripAlert.isPresentedAlert = true
    }
    
    func refreshAll() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred() //产生震动提示
        self.timeline.refreshFromTop(fh: failureHandler(error:))
    }
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}



