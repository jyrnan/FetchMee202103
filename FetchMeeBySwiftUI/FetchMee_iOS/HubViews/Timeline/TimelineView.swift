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
    
    @State var isShowFloatComposer:Bool = false
    
//    @State var expandingIDString: String? //标记视图中需要展开显示ToolsView的TweetRowID
    
    var listName: String? //如果是list类型则会传入listName
    init(timeline: Timeline, listName: String? = nil) {
        self.timeline = timeline
        self.listName = listName
        
    }
    
    @GestureState var dragAmount = CGSize.zero
    
    var body: some View {
        GeometryReader {proxy in
            List{
                
                //Homeline部分章节
                ZStack{
                    RoundedCorners(color: Color.init("BackGround"), tl: 24, tr: 24, bl: 0, br: 0)
                        .frame(height: 60)
                        .foregroundColor(Color.init("BackGround"))
                    
                    PullToRefreshView(action: self.refreshAll, isDone: self.$timeline.isDone) {
                        Composer(isProcessingDone: $timeline.isDone)
                    }
                    .frame(height: 36)
                    .padding(.horizontal, 16)
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                ForEach(self.timeline.tweetIDStrings, id: \.self) {tweetIDString in
                    
                    TweetRow(viewModel: timeline.getTweetViewModel(tweetIDString: tweetIDString, width: proxy.size.width))
                        .onAppear{
                            timeline.fetchMoreIfNeeded(tweetIDString: tweetIDString)
                            
                            ///如果是顶端推文显示，或者说回到顶端，那么则调用减少推文函数
                            if timeline.tweetIDStrings.first == tweetIDString {
                                timeline.reduceTweetsIfNeed()
                            }
                            
                        }
                    
                }
                
                HStack {
                    Spacer()
                    if !timeline.isDone {
                        ActivityIndicator(isAnimating: $timeline.isDone, style: .medium)
                    }
                    Button(timeline.isDone ? "More Tweets..." : "Fetching...") {self.timeline.refreshFromBottom()}
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(height: 24)
                    Spacer()
                }
                .listRowBackground(Color.init("BackGround"))
                
                
                RoundedCorners(color: Color.init("BackGround"), tl: 0, tr: 0, bl: 24, br: 24)
                    .frame(height: 42)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
            }
            .gesture(DragGesture()
                        .onChanged({ value in
                            hideKeyboard()
                            delay(delay: 0.5){ timeline.removeToolsView()}
                            
                        })
            )
            
            .navigationTitle(listName ?? timeline.type.rawValue)
            .onAppear {
                if timeline.tweetIDStrings.isEmpty {
                    timeline.refreshFromBottom(count: 20)
                }
            }
            .onDisappear{
                timeline.reduceTweetsIfNeed()
                timeline.removeTweetRowModelIfNeed()
                print(#line, #file, "timelineView disappeared")
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
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}



