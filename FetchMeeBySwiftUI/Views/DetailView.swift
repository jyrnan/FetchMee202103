//
//  DetailView.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI


struct DetailView: View {
    @EnvironmentObject var alerts: Alerts
    
    @ObservedObject var replySession: Timeline = Timeline(type: .session)
    @ObservedObject var kGuardianOfDetailView: KeyboardGuardian = KeyboardGuardian(textFieldCount: 1)
     var tweetIDString: String //传入DetailView的初始推文
    
    @State var firstTimeRun: Bool = true
    @Binding var isShowDetail: Bool  //用于绑定页面是否显示的开关，但是目前没有使用

    var body: some View {
        List{
            HStack{
                Text("Session").font(.largeTitle).bold()
                Spacer()
                ActivityIndicator(isAnimating: self.$replySession.isDone, style: .medium)
            }
            .padding(.top, 20)
            
            if self.alerts.stripAlert.isPresentedAlert {
                AlertView(isAlertShow: self.$alerts.stripAlert.isPresentedAlert, alertText: self.alerts.stripAlert.alertText)
            } //Alert视图，待定
            
            ForEach(replySession.tweetIDStrings, id: \.self) {tweetIDString in
                TweetRow(timeline: replySession, tweetIDString: tweetIDString, kGuardian: self.kGuardianOfDetailView)
            }
        }
        .offset( y: self.kGuardianOfDetailView.slide).animation(.easeInOut(duration: 0.2))
        .onAppear {
            self.kGuardianOfDetailView.addObserver()
            if self.firstTimeRun {
                self.firstTimeRun = false
                self.replySession.getReplyDetail(for: self.tweetIDString)
            } else {print(#line, "firstTimeRun is already true")}} //页面出现时执行一次刷新
        .onDisappear {self.kGuardianOfDetailView.removeObserver()}
    }
    
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(tweetIDString: "", isShowDetail: .constant(true))
    }
}
