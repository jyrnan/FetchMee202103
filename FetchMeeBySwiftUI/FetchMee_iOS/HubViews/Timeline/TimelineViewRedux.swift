//
//  TimelineViewRedux.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/26.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine
import UIKit

struct TimelineViewRedux: View {
    @EnvironmentObject var store: Store
    
    var timelineType: TimelineType
    var timeline: AppState.TimelineData.Timeline
    {
        switch timelineType {
        case .home:
            return store.appState.timelineData.home
        case .mention:
            return  store.appState.timelineData.mention
        default:
            return AppState.TimelineData.Timeline()
        }
    }
    @State var tweetText: String = ""
    
    @State var isShowFloatComposer:Bool = false
    
    @State private var isProcessingDone: Bool = true
        
    var listName: String? //如果是list类型则会传入listName
   
    
    @GestureState var dragAmount = CGSize.zero
    
    var body: some View {
        GeometryReader {proxy in
            List{
                
                //Homeline部分章节
                ZStack{
                    RoundedCorners(color: Color.init("BackGround"), tl: 24, tr: 24, bl: 0, br: 0)
                        .frame(height: 60)
                        .foregroundColor(Color.init("BackGround"))
                    
                    PullToRefreshView(action: refreshAll, isDone: self.$isProcessingDone) {
                        Composer(isProcessingDone: $isProcessingDone)
                    }
                    .frame(height: 36)
                    .padding(.horizontal, 16)
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                ForEach(store.appState.timelineData.home.tweetIDStrings, id: \.self) {tweetIDString in
                    
                    TweetRow(viewModel: TweetRowViewModel(timeline: Timeline(type: timelineType), tweetIDString: tweetIDString, width: proxy.size.width))
                        .onAppear{
//                            timeline.fetchMoreIfNeeded(tweetIDString: tweetIDString)
                            
                            ///如果是顶端推文显示，或者说回到顶端，那么则调用减少推文函数
                            if timeline.tweetIDStrings.first == tweetIDString {
//                                timeline.reduceTweetsIfNeed()
                            }
                            
                        }
                    
                }
                
                HStack {
                    Spacer()
//                    if !isProcessingDone {
//                        ActivityIndicator(isAnimating: $isProcessingDone, style: .medium)
//                    }
                    Button(isProcessingDone ? "More Tweets..." : "Fetching...") {
//                        self.timeline.refreshFromBottom()
                        store.dipatch(.updateTimeline(timeline: .home, mode: .bottom))
                    }
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
                            hideKeyboard()}))
            
            .navigationTitle(listName ?? timeline.type.rawValue)
//            .navigationBarItems( trailing: Button(action: {
//                alerts.isShowingOverlaySheet = true
//            }, label: {
//                Image(systemName: "plus").font(.title2)
//            }))
            .onAppear {
                if timeline.tweetIDStrings.isEmpty {
//                    timeline.refreshFromBottom(count: 20)
                }
            }
            .onDisappear{
//                timeline.reduceTweetsIfNeed()
//                timeline.removeTweetRowModelIfNeed()
                print(#line, #file, "timelineView disappeared")
            }
            
        }
    }
}

extension TimelineViewRedux {
    /**
     处理出错的handler，可以传入到timeline里面执行。
     */
    func failureHandler(error: Error) -> Void {
        print(#line, error.localizedDescription)
//        self.alerts.stripAlert.alertText = "Sorry! Network error!"
//        self.alerts.stripAlert.isPresentedAlert = true
    }
    
    func refreshAll() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred() //产生震动提示
        store.dipatch(.updateTimeline(timeline: .home, mode: .top))
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

