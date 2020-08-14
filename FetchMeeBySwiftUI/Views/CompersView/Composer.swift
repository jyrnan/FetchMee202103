//
//  Composer.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct Composer: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    
    @ObservedObject var timeline : Timeline
    @State var tweetText: String = ""
    
    @State var isShowCMV: Bool = false  //是否显示详细新推文视图
    
    var tweetIDString: String?
    
    
    var body: some View {
        HStack(alignment: .center) {
            TextField("Tweet something here...", text: $tweetText).font(.body).padding(.leading, 16)
            Spacer()
            if self.timeline.isDone {
                Text("more").font(.body).foregroundColor(.primary).opacity(0.7)
//            Image(systemName: "photo").resizable().aspectRatio(contentMode: .fit).frame(width: 16, height: 16, alignment: .center).foregroundColor(.gray)
                .onTapGesture {self.isShowCMV = true }
                .sheet(isPresented: self.$isShowCMV) {
                    ComposerMoreView(isShowCMV: self.$isShowCMV, tweetText: self.tweetText, replyIDString: self.tweetIDString).environmentObject(user).accentColor(self.user.myInfo.setting.themeColor.color)
                } } else {
                    ActivityIndicator(isAnimating: self.$timeline.isDone, style: .medium)
                }
            
            Divider()
//            Text(self.tweetText == "" ? "Tweet" : "Tweet" )
            Image(systemName: "message.circle.fill").resizable().aspectRatio(contentMode: .fill).frame(width: 24, height: 24, alignment: .center).padding(.trailing, 6)
                .foregroundColor(self.tweetText == "" ? Color.primary.opacity(0.3) : Color.primary.opacity(0.8) )
                .onTapGesture {
                if self.tweetText != "" {
                    self.timeline.isDone = false
                    swifter.postTweet(status: self.tweetText, inReplyToStatusID: tweetIDString, autoPopulateReplyMetadata: true, success: {_ in
                        switch self.timeline.type { //如果是在detail视图则不更新timeline
                        case .session:
                            print(#line, self.tweetIDString as Any)
                            self.timeline.isDone = true
                            self.alerts.stripAlertOfDetailView.alertText = "Reply sent!"
                            self.alerts.stripAlertOfDetailView.isPresentedAlert = true
                        default:
                            self.timeline.refreshFromTop()
                            self.alerts.stripAlert.alertText = "Tweet sent!"
                            self.alerts.stripAlert.isPresentedAlert = true
                        }  
                    })
                    self.tweetText = ""
                    self.hideKeyboard()
                    
                } else {
                    print(#line, "nothing")
                }
            }
        }
    }
}

extension Composer {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct Composer_Previews: PreviewProvider {
    static var previews: some View {
        Composer(timeline: Timeline(type: .home))
    }
}
