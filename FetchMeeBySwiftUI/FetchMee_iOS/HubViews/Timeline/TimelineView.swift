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
                    if tweetIDString.contains("toolsView") {
                        ToolsView(viewModel: timeline.toolsViewModel)
                                .padding(.top, 16)
                                .listRowBackground(Color.init("BackGround"))
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    } else {
                        TweetRow(viewModel: timeline.getTweetViewModel(tweetIDString: tweetIDString, width: proxy.size.width))
                            .onTapGesture {
                                withAnimation(){
                                    timeline.toggleToolsView(tweetIDString: tweetIDString)
                                    
                                }
                                
                            }
                        
                    }
                        
                }
                
//                .onDelete(perform: {indexSet in timeline.addToolsView(indexSet: indexSet)})
                
                
                HStack {
                    Spacer()
                    Button("More Tweets...") {self.timeline.refreshFromBottom()}
                        .font(.caption)
                        .frame(height: 24)
                    Spacer()
                }
                .listRowBackground(Color.init("BackGround"))
                RoundedCorners(color: Color.init("BackGround"), tl: 0, tr: 0, bl: 24, br: 24)
                    .frame(height: 42)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
            }
            
            
            .navigationTitle(listName ?? timeline.type.rawValue)
            .onAppear {
                if timeline.tweetIDStrings.isEmpty {
                    timeline.refreshFromTop()
                }
            }
            //            .onTapGesture {
            //                hideKeyboard()
            //            }
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



