//
//  DetailView.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine


struct DetailView: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    
    @ObservedObject var replySession: Timeline = Timeline(type: .session)
     var tweetIDString: String //传入DetailView的初始推文
    
    @State var firstTimeRun: Bool = true
    @Binding var isShowDetail: Bool  //用于绑定页面是否显示的开关，但是目前没有使用
    @State var keyboardHeight: CGFloat = 0
    
    var body: some View {
        NavigationView {
            List{
//                HStack{
//                    Text("Session").font(.largeTitle).bold()
//                    Spacer()
//                    ActivityIndicator(isAnimating: self.$replySession.isDone, style: .medium)
//                }
//                .padding(.top, 20)
                
                if self.alerts.stripAlert.isPresentedAlert {
                    AlertView(isAlertShow: self.$alerts.stripAlert.isPresentedAlert, alertText: self.alerts.stripAlert.alertText)
                } //Alert视图，待定
                
                ForEach(replySession.tweetIDStrings, id: \.self) {tweetIDString in
                    TweetRow(timeline: replySession, tweetIDString: tweetIDString)
                }
                Composer(timeline: self.replySession, tweetIDString: self.tweetIDString)
            }
            .onReceive(Publishers.keyboardHeight) {
                self.keyboardHeight = $0
                print(#line, self.keyboardHeight)
            }
            .offset(y: self.keyboardHeight != 0 ? -1 : 0)
            .onAppear {
                if self.firstTimeRun {
                    self.firstTimeRun = false
                    self.replySession.getReplyDetail(for: self.tweetIDString)
                } else {print(#line, "firstTimeRun is already true")}} //页面出现时执行一次刷新
            .navigationBarTitle("Detail")
            .navigationBarItems(trailing: ActivityIndicator(isAnimating: self.$replySession.isDone, style: .medium))
        }
        
    }
    
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(tweetIDString: "", isShowDetail: .constant(true))
    }
}
