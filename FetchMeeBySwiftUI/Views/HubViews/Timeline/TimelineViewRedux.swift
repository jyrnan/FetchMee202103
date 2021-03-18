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
    
    ///创建一个简单表示法
    var setting: UserSetting {store.appState.setting.loginUser?.setting ?? UserSetting()}
    
    var timelineType: TimelineType
    var timeline: AppState.TimelineData.Timeline { store.appState.timelineData.getTimeline(timelineType: timelineType)}
    
    @State var tweetText: String = ""
    var isProcessingDone: Binding<Bool>  {$store.appState.setting.isProcessingDone}
    @GestureState var dragAmount = CGSize.zero
    
    @State var numberOfReadTweet: Int = 0
    
    var selectedBackgroudColor: some View  {
        Color.init("BackGround")
            .overlay(Color.accentColor.opacity(0.12))}
    
    
    var body: some View {
        GeometryReader {proxy in
            List{
                
                //                Homeline部分章节
                ZStack{
                    RoundedCorners(color: Color.init("BackGround"), tl: 24, tr: 24, bl: 0, br: 0)
                        .frame(height: 44)
                        .foregroundColor(Color.init("BackGround"))
                    
                    PullToRefreshView(action: refreshAll, isDone: self.isProcessingDone) {
                        //                        Composer(isProcessingDone: isProcessingDone)
                        Spacer()
                    }
                    .frame(height: 36)
                    .padding(.horizontal, 16)
                    
                    HStack {
                        Spacer()
                        if !store.appState.setting.isProcessingDone {
                            ActivityIndicator(isAnimating: $store.appState.setting.isProcessingDone, style: .medium).frame(width: 12, height: 12, alignment: .center).padding(.trailing, 16)
                        }
                    }
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                ForEach(timeline.tweetIDStrings, id: \.self) {tweetIDString in
                    if tweetIDString != "toolsViewMark" {
                        VStack(spacing: 0){
                        StatusRow(tweetID: tweetIDString, width: proxy.size.width - 2 * setting.uiStyle.insetH)
                            .background(setting.uiStyle.backGround)
                            .cornerRadius(setting.uiStyle.radius, antialiased: true)
                            .overlay(RoundedRectangle(cornerRadius: setting.uiStyle.radius)
                            .stroke(setting.uiStyle.backGround, lineWidth: 1))
                            .padding(.horizontal, setting.uiStyle.insetH)
                            .padding(.vertical, setting.uiStyle.insetV)
                            ///下面这个background可以遮蔽List的分割线
                            .background(Color.init("BackGround"))
                            .onAppear{
                                numberOfReadTweet += 1
                                if store.appState.setting.loginUser?.setting.isAutoFetchMoreTweet == true {
                                    fetchMoreIfNeeded(tweetIDString: tweetIDString) }
                            }
                        if setting.uiStyle == .plain {
                            Divider().padding(0)
                        }
                        }
                    } else {
                        ToolsView(tweetIDString: store.appState.timelineData.selectedTweetID ?? "")
//                            .listRowBackground(selectedBackgroudColor)
                            .padding(.horizontal, setting.uiStyle.insetH)
                            .padding(.vertical,setting.uiStyle.insetV)
                            .background(Color.init("BackGround"))
                    }
                    
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0,trailing: 0))
                
                HStack {
                    Spacer()
                    if !isProcessingDone.wrappedValue {
                        ActivityIndicator(isAnimating: isProcessingDone, style: .medium)
                    }
                    Button(isProcessingDone.wrappedValue ? "More Tweets..." : "Fetching...") {
                        store.dipatch(.fetchTimeline(timelineType: timelineType, mode: .bottom))
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
            
            .navigationTitle(timeline.type.rawValue)
            .onAppear {
                store.dipatch(.fetchTimeline(timelineType: timelineType, mode: .top))
            }
            .onDisappear{
                store.dipatch(.updateNewTweetNumber(timelineType: timelineType, numberOfReadTweet: numberOfReadTweet))
            }
            
        }
    }
}

extension TimelineViewRedux {
    
    func refreshAll() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred() //产生震动提示
        store.dipatch(.fetchTimeline(timelineType: timelineType, mode: .top))
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
    /// 如果推文属于timeline后端，则往下刷新推文。
    /// - Parameter tweetIDString: 执行此操作的推文ID
    func fetchMoreIfNeeded(tweetIDString: String) {
        ///需要往下刷新推文的推文位置，是从后倒数
        let shouldFetchIndex = 5
        guard timeline.tweetIDStrings.count > shouldFetchIndex else {return}
        let index = timeline.tweetIDStrings.count - shouldFetchIndex
        if timeline.tweetIDStrings[index] == tweetIDString {
            store.dipatch(.fetchTimeline(timelineType: timelineType, mode: .bottom))
        }
    }
}

