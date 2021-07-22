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
    @Environment(\.presentationMode) var presentationMode
    
    var timeline: AppState.TimelineData.Timeline
    
    @State var tweetText: String = ""
    @GestureState var dragAmount = CGSize.zero
    
    @State var readCounter: Int = 0
    @State var isShowCMV: Bool = false
    @State var statusToReply: Status?
    @State var statusIDOfDetail: Status?
    
    init(timeline: AppState.TimelineData.Timeline) {
        self.timeline = timeline
        print(#line, "init of timeline \(timeline.type.rawValue)")
    }
    
    //MARK: - View定义
    
    var timelineTop: some View {
        ZStack{
            RoundedCorners(color: Color.init("BackGround"), tl: 18, tr: 18, bl: 0, br: 0)
            HStack {
                ProgressView()
                    .padding(.trailing, 8)
                Text("Fetching...")
                    .font(.caption)
            }.foregroundColor(.secondary)
                .opacity(store.appState.setting.isProcessingDone ? 0 : 1.0)
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
    
    var timelineBottom: some View {
        ZStack{
            RoundedCorners(color: Color.init("BackGround"), tl: 0, tr: 0, bl: 18, br: 18)
                .onAppear{
                    guard store.appState.setting.isProcessingDone == true else {return}
                    guard store.appState.setting.userSetting?.isAutoFetchMoreTweet == true else {return}
                    store.dispatch(.fetchTimeline(timelineType: timeline.type, mode: .bottom))
                }
            Button(action: {store.dispatch(.fetchTimeline(timelineType: timeline.type, mode: .bottom))},
                   label: {
                HStack{
                    Spacer()
                    ProgressView()
                        .padding(.trailing, 8)
                        .opacity(store.appState.setting.isProcessingDone ? 0 : 1.0)
                    Text(store.appState.setting.isProcessingDone ? "More Tweets..." : "Fetching...")
                    Spacer()
                }
                .font(.caption).foregroundColor(.secondary)
            })
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
    
    var fakeTimelineBody: some View {
        ForEach(1..<6) {_ in
            FakeStatusRow()
                .background(store.appState.setting.userSetting?.uiStyle.backGround)
                .cornerRadius(store.appState.setting.userSetting?.uiStyle.radius ?? 0,
                              antialiased: true)
                .padding(.horizontal, store.appState.setting.userSetting?.uiStyle.insetH)
                .padding(.vertical, store.appState.setting.userSetting?.uiStyle.insetV)
                .background(Color.init("BackGround"))
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0,trailing: 0))
        .listRowSeparator(store.appState.setting.userSetting?.uiStyle == .card ? .hidden : .visible)
    }
    
    @ViewBuilder func timelineBody(proxy: GeometryProxy) -> some View {
        ForEach(timeline.tweetIDStrings.compactMap{store.appState.timelineData.statuses[$0]}, id: \.id) {status in
           
            StatusRow(status: status,
                      width: proxy.size.width - (2 * (store.appState.setting.userSetting?.uiStyle.insetH ?? 0)))
                .background(store.appState.setting.userSetting?.uiStyle.backGround)
                .cornerRadius(store.appState.setting.userSetting?.uiStyle.radius ?? 0,
                              antialiased: true)
                .padding(.horizontal, store.appState.setting.userSetting?.uiStyle.insetH)
                .padding(.vertical, store.appState.setting.userSetting?.uiStyle.insetV)
                .background(Color.init("BackGround"))
                .onAppear{
                    readCounter += 1
                }
                .onTapGesture{
                    store.dispatch(.initialAndFetchSessionData(status: status))
                    statusIDOfDetail = status
//                    store.dispatch(.fetchSession(tweetIDString: status.id))
                }
                .swipeActions {
                    Button{
                        statusToReply = status
                    } label: {
                        Label("Reply", systemImage: "arrowshape.turn.up.left")
                    }.tint(.blue)
                    
                    Button{
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        if isTweetByMeself(status) {
                            store.dispatch(.tweetOperation(operation: .delete(id: status.id)))
                        } else {
                            
                            store.fetcher.swifter.getTweet(for: status.id, success: {json in
                                let _ = StatusCD.JSON_Save(from: json, isBookmarked: true)
                                store.dispatch(.alertOn(text: "Bookmarked!", isWarning: false))
                                store.dispatch(.hubStatusRequest)
                            })
                        }
                        
                    } label: {
                        Label(isTweetByMeself(status) ? "Del" : "Save",
                              systemImage: isTweetByMeself(status) ? "trash" : "bookmark")
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
                            Label("\(status.retweet_count)", systemImage: "arrow.2.squarepath")
                        } else {
                            Label("\(status.retweet_count)", systemImage: "arrow.2.squarepath")
                        }
                    }
                    .tint(.green)
                }
            
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0,trailing: 0))
        .listRowSeparator(store.appState.setting.userSetting?.uiStyle == .card ? .hidden : .visible)
    }
    
    
    var body: some View {
        GeometryReader {proxy in
            List{
                timelineTop
                
                if timeline.tweetIDStrings.isEmpty {
                    fakeTimelineBody
                        .task{fetchMoreIfNoNewMention()}
                } else {
                    timelineBody(proxy: proxy)
                }
                
                timelineBottom
            }
            .listStyle(.plain)
            .navigationTitle(timeline.type.rawValue)
            .onDisappear{
                updateNewTweetNumber()
            }
            .refreshable {
                fetchTimelineFromTop()
            }
            .sheet(item: $statusToReply){status in
                //sheet必须在最外层，这样不会产生dogesheet
                ComposerOfHubView(swifter: store.fetcher.swifter,
                                  tweetText: $store.appState.setting.tweetInput.tweetText,
                                  replyIDString: status.id,
                                  isUsedAlone: true,
                                  status: status)
                    .accentColor(store.appState.setting.userSetting?.themeColor.color)
            }
            .sheet(item: $statusIDOfDetail){ status in
                DetailViewSheet(status: status)
                    .accentColor(store.appState.setting.userSetting?.themeColor.color)
            }
        }
    }
}

//MARK: - func

extension TimelineView {
    
    fileprivate func updateNewTweetNumber() {
        store.dispatch(.updateNewTweetNumber(timelineType: timeline.type, numberOfReadTweet: readCounter))
    }
    
    /// 如果是MentionTimeline，并且没有更新的mention，则从底部开始刷新，也就是显示最近的旧推文
    fileprivate func fetchMoreIfNoNewMention() {
        guard timeline.tweetIDStrings.isEmpty, timeline.type == .mention else {return}
        store.dispatch(.fetchTimeline(timelineType: .mention, mode: .bottom))
    }
    
    func fetchTimelineFromTop() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred() //产生震动提示
        print(#function)
        store.dispatch(.fetchTimeline(timelineType: timeline.type, mode: .top))
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func isTweetByMeself(_ status: Status) -> Bool {
        return status.user?.id == store.appState.setting.loginUser?.id
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView(timeline: Store.sample.appState.timelineData.getTimeline(timelineType: .home))
            .environmentObject(Store.sample)
    }
}

