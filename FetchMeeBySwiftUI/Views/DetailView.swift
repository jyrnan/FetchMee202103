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
    var tweetIDString: String
    @State var firstTimeRun: Bool = true
    @Binding var isShowDetail: Bool
    
//    init(tweetIDString: String) {
//        //        self.replySession = replySession
//        self.tweetIDString = tweetIDString
//        print(#line, "DetailView created!")
//    }
    
    var body: some View {
        List{
//            if !replySession.isDone {
//                HStack {
//                    Spacer()
//                    ActivityIndicator(isAnimating: self.$replySession.isDone, style: .medium)
//
//                    Spacer()
//                }
//            }
            HStack{
                
                Text("Session").font(.largeTitle).bold()
                Spacer()
                ActivityIndicator(isAnimating: self.$replySession.isDone, style: .medium)
            }.padding(.top, 20)
            if self.alerts.stripAlert.isPresentedAlert {
                AlertView(isAlertShow: self.$alerts.stripAlert.isPresentedAlert, alertText: self.alerts.stripAlert.alertText)
            }
            Composer(timeline: replySession, tweetIDString: tweetIDString, someToggle: self.$isShowDetail )
            ForEach(replySession.tweetIDStrings, id: \.self) {tweetIDString in
                TweetRow(timeline: replySession, tweetIDString: tweetIDString)
            }
        }
        .onAppear {
            print(#line, "onAppear")
            print(#line, firstTimeRun)
            if self.firstTimeRun {
                self.firstTimeRun = false
                print(#line, "set firstTimeRun to \(self.firstTimeRun)")
                self.replySession.getReplyDetail(for: self.tweetIDString)
                print(#line, "onAppear")
            } else {
                print(#line, "firstTimeRun is already true")
            }}
    }
    
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(tweetIDString: "", isShowDetail: .constant(true))
    }
}
