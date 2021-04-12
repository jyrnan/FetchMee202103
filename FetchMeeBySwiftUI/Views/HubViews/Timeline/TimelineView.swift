//
//  TimelineView.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/26.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine
import UIKit

struct TimelineView: View {
    @EnvironmentObject var store: Store
    
    ///创建一个简单表示法
    var setting: UserSetting {store.appState.setting.userSetting ?? UserSetting()}
    
    var timelineType: TimelineType
    var timeline: AppState.TimelineData.Timeline { store.appState.timelineData.getTimeline(timelineType: timelineType)}
    
    @State var tweetText: String = ""
    var isProcessingDone: Binding<Bool>  {$store.appState.setting.isProcessingDone}
    @GestureState var dragAmount = CGSize.zero
    
    var selectedBackgroudColor: some View  {
        Color.init("BackGround")
            .overlay(Color.accentColor.opacity(0.12))}
    
    
    var body: some View {
        GeometryReader {proxy in
            List{
                
                //Homeline部分章节
                ZStack{
                    RoundedCorners(color: Color.init("BackGround"), tl: 24, tr: 24, bl: 0, br: 0)
                        .frame(height: 44)
                        .foregroundColor(Color.init("BackGround"))
                    
                    PullToRefreshView(action: refreshAll, isDone: self.isProcessingDone) {
                        Spacer()
                    }
                    .frame(height: 36)
                    .padding(.horizontal, 16)
                    
                    HStack {
                        Spacer()
                        if !store.appState.setting.isProcessingDone {
                            ActivityIndicator(isAnimating: isProcessingDone, style: .medium).frame(width: 12, height: 12, alignment: .center).padding(.trailing, 16)
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
                                checkNeededActions(tweetIDString: tweetIDString)
                            }
                            
                        if setting.uiStyle == .plain {
                            Divider().padding(0)
                        }
                        }
                    } else {
                        ToolsView(tweetIDString: store.appState.timelineData.selectedTweetID ?? "")
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
                        .onChanged({ value in hideKeyboard()}))
            .navigationTitle(timeline.type.rawValue)
            
        }
    }
}

extension TimelineView {
    
    func refreshAll() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred() //产生震动提示
        store.dipatch(.fetchTimeline(timelineType: timelineType, mode: .top))
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
   
    /// 判断该推文出现的时候需要采取的操作
    /// 可能包括刷新最新推文数量和获取新的推文
    /// - Parameter tweetIDString: 执行此操作的推文ID
    func checkNeededActions(tweetIDString: String) {
        guard timeline.tweetIDStrings.count > 10 else {return}
        //如果是第十条推文，则更新新推文数量，减少100条新推文（相当于设置新推文数量为0）
        let indexOfUpdateNewTweetNumber = 10
        if timeline.tweetIDStrings[indexOfUpdateNewTweetNumber] == tweetIDString,
           timeline.newTweetNumber != 0 {
            store.dipatch(.updateNewTweetNumber(timelineType: timelineType, numberOfReadTweet: 1000))
        }
        //如果推文是倒数第5条，则获取更早之前的推文
        let index = timeline.tweetIDStrings.count - 5
        if timeline.tweetIDStrings[index] == tweetIDString {
            store.dipatch(.fetchTimeline(timelineType: timelineType, mode: .bottom))
        }
    }
}

