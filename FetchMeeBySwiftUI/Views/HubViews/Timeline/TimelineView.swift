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
    ///自定义返回按钮的范例
    //    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    //
    //        var btnBack : some View { Button(action: {
    //            self.presentationMode.wrappedValue.dismiss()
    //            }) {
    //                HStack {
    //                Image("Logo") // set image here
    //                    .resizable()
    //                    .aspectRatio(contentMode: .fit)
    //                    .foregroundColor(.white)
    //                    .frame(width: 24, height: 24, alignment: .center)
    //                    Text("Back")
    //                }
    //            }
    //        }
    
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var downloader: Downloader
    
    @ObservedObject var timeline: Timeline
    
    @State var tweetText: String = ""
    
    var listName: String? //如果是list类型则会传入listName
    init(timeline: Timeline, listName: String?) {
        self.timeline = timeline
        self.listName = listName
        
    }
    
    var body: some View {
        
        ScrollView(.vertical) {
            PullToRefreshView(action: self.refreshAll, isDone: self.$timeline.isDone) {
                Composer(timeline: self.timeline)}
                .frame(height: 36)
                .background(Color.init("BackGround"))
                .cornerRadius(18)
                .padding([.leading, .trailing,.top], 16)
            
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
                    Button("More Tweets...") {self.timeline.refreshFromBottom()}
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(height: 24)
                    Spacer()
                }.background(Color.init("BackGround")) //下方载入更多按钮
                RoundedCorners(color: Color.init("BackGround"), bl: 18, br: 18 ).frame(height: 18)
            }.padding([.leading, .trailing], 16)
            
        }
        .navigationTitle(listName ?? timeline.type.rawValue)
//        .navigationBarTitleDisplayMode(.inline)
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



