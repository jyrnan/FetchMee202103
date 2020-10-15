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
    @EnvironmentObject var user: User
    @EnvironmentObject var downloader: Downloader
    
    @ObservedObject var timeline: Timeline
    
    @State var tweetText: String = ""
    @State var listName: String? //如果是list类型则会传入listName
    
    var body: some View {
        
        ZStack {
            ScrollView(.vertical) {
                PullToRefreshView(action: self.refreshAll, isDone: self.$timeline.isDone) {
                    Composer(timeline: self.timeline)}.frame(height: 36).background(Color.init("BackGround")).cornerRadius(18).padding([.leading, .trailing], 16)
                
                //Homeline部分章节
                LazyVStack(spacing: 0) {
                    RoundedCorners(color: Color.init("BackGround"), tl: 18, tr: 18 ).frame(height: 18)
                    
                    ForEach(self.timeline.tweetIDStrings, id: \.self) {
                        tweetIDString in
                        //
                        TweetRow(timeline: timeline, tweetIDString: tweetIDString)
                            .onTapGesture {
                                self.timeline.tweetMedias[tweetIDString]?.isToolsViewShowed = true
                            }
                            .background(userDefault.object(forKey: "userIDString") as? String == self.timeline.tweetMedias[tweetIDString]?.in_reply_to_user_id_str && timeline.type == .home ? Color.accentColor.opacity(0.2) : Color.init("BackGround")) //在HomeTimeline标注被提及的推文
                        
                        Divider()
                    }
                    
                    HStack {
                        Spacer()
                        Button("More Tweets...") {self.timeline.refreshFromButtom()}
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(height: 24)
                        Spacer()
                    }.background(Color.init("BackGround")) //下方载入更多按钮
                    RoundedCorners(color: Color.init("BackGround"), bl: 18, br: 18 ).frame(height: 18)
                }.padding([.leading, .trailing], 16)
                
            }
            .navigationBarTitle(listName ?? timeline.type.rawValue, displayMode: .automatic)
            .navigationBarItems(leading:
                                    HStack{
                                        if downloader.taskCount != 0 {
                                            Text("\(downloader.taskCount) pictures downloading...")
                                                .font(.caption).foregroundColor(.gray)
                                        }
                                    },
                                trailing:
                                    AvatarImageView(image: user.myInfo.avatar).frame(width: 36, height: 36, alignment: .center))
            //通知视图
            AlertView()
        }
        .onAppear {
            if timeline.tweetIDStrings.isEmpty {
                timeline.refreshFromTop()
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

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView(timeline: Timeline(type: .home))
    }
}
