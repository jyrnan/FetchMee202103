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
    
    var timeline: AppState.TimelineData.Timeline
    
    @State var tweetText: String = ""
    @GestureState var dragAmount = CGSize.zero
    
    @State var readCounter: Int = 0
    @State var isShowCMV: Bool = false
    @State var statusToReply: Status = Status()
    
    var body: some View {
        GeometryReader {proxy in
            List{
                
                //Homeline部分章节
                ZStack{
                    RoundedCorners(color: Color.init("BackGround"), tl: 18, tr: 18, bl: 0, br: 0)
                    
                    HStack {
                        Spacer()
                        ActivityIndicator(isAnimating: $store.appState.setting.isProcessingDone, style: .medium)
                            .frame(width: 12, height: 12, alignment: .center)
                            .padding(.trailing, 16)
                            .opacity(store.appState.setting.isProcessingDone ? 0 : 1 )
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .background(Color.init(.systemBackground))
                
                
                ForEach(timeline.tweetIDStrings.map{store.repository.getStatus(byID: $0)}, id: \.id) {status in
                    
                    StatusRow(status: status,
                              width: proxy.size.width - 2 * (store.appState.setting.userSetting?.uiStyle.insetH ?? 0))
                        .background(store.appState.setting.userSetting?.uiStyle.backGround)
                        .cornerRadius(store.appState.setting.userSetting?.uiStyle.radius ?? 0,
                                      antialiased: true)
                        .overlay(RoundedRectangle(cornerRadius: 16)
                                    .stroke(store.appState.setting.userSetting?.uiStyle.backGround ?? Color.black, lineWidth: 1))
                        .padding(.horizontal, store.appState.setting.userSetting?.uiStyle.insetH)
                        .padding(.vertical, store.appState.setting.userSetting?.uiStyle.insetV)
                        .background(Color.init("BackGround"))
                        .onAppear{
                            readCounter += 1
                        }
                        .swipeActions {
                            Button{
                                statusToReply = status
                                isShowCMV = true
                            } label: {
                                Label("Reply", systemImage: "arrowshape.turn.up.left")
                            }.tint(.blue)
                            Button{print("Delete")} label: {
                                Label("Del", systemImage: "house")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                store.dispatch(.tweetOperation(operation: status.favorited ? .unfavorite(id: status.id) : .favorite(id: status.id)))
                            } label: {
                                Label("\(status.favorite_count)", systemImage: "heart")
                            }
                            .tint(.red)
                            
                            Button {
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                store.dispatch(.tweetOperation(operation: status.retweeted ? .unRetweet(id: status.id) : .retweet(id: status.id)))
                            } label: {
                                if status.retweeted {
                                    Label("\(status.retweet_count)", systemImage: "repeat.1")
                                } else {
                                    Label("\(status.retweet_count)", systemImage: "repeat")
                                }
                            }
                            .tint(.green)
                        }
                        
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0,trailing: 0))
                .listRowSeparator(.hidden)
                .sheet(isPresented: $isShowCMV){ComposerOfHubView(swifter: store.fetcher.swifter,
                                                                   tweetText: $store.appState.setting.tweetInput.tweetText,
                                                                   replyIDString: statusToReply.id,
                                                                   isUsedAlone: true,
                                                                   status: statusToReply)
                 .accentColor(store.appState.setting.userSetting?.themeColor.color)
                 }
                
                
                
                HStack {
                    Spacer()
                    if !store.appState.setting.isProcessingDone {
                        ActivityIndicator(isAnimating: $store.appState.setting.isProcessingDone, style: .medium)
                    }
                    Button(store.appState.setting.isProcessingDone ? "More Tweets..." : "Fetching...") {
                        store.dispatch(.fetchTimeline(timelineType: timeline.type, mode: .bottom))
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(height: 24)
                    Spacer()
                }
                .listRowBackground(Color.init("BackGround"))
                
                RoundedCorners(color: Color.init("BackGround"), tl: 0, tr: 0, bl: 24, br: 24)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                //                    .background(Color.init(.systemBackground))
                    .onAppear{
                        guard store.appState.setting.isProcessingDone == true else {return}
                        store.dispatch(.fetchTimeline(timelineType: timeline.type, mode: .bottom))
                    }
                
            }
            .listStyle(.plain)
            .navigationTitle(timeline.type.rawValue)
            .onDisappear{
                store.dispatch(.updateNewTweetNumber(timelineType: timeline.type, numberOfReadTweet: readCounter))
            }
            .refreshable {
                refreshAll()
            }
        }
    }
}

extension TimelineView {
    
    func refreshAll() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred() //产生震动提示
        store.dispatch(.fetchTimeline(timelineType: timeline.type, mode: .top))
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
            store.dispatch(.updateNewTweetNumber(timelineType: timeline.type, numberOfReadTweet: 1000))
        }
        //如果推文是倒数第5条，则获取更早之前的推文
        let index = timeline.tweetIDStrings.count - 5
        if timeline.tweetIDStrings[index] == tweetIDString {
            store.dispatch(.fetchTimeline(timelineType: timeline.type, mode: .bottom))
        }
    }
}


struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView(timeline: AppState.TimelineData.Timeline())
            .environmentObject(Store())
    }
}
