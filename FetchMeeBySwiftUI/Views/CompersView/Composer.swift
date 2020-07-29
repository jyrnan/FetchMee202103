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
    @ObservedObject var timeline : Timeline
    @State var tweetText: String = ""
    
    @State var isShowCMV: Bool = false
        
    var tweetIDString: String?
    
    
    var body: some View {
        HStack(alignment: .center) {
            TextField("Tweet something here...", text: $tweetText).font(.body)
            Spacer()
//            Text("More").font(.body).foregroundColor(.gray)
            Image(systemName: "photo").resizable().aspectRatio(contentMode: .fit).frame(width: 16, height: 16, alignment: .center).foregroundColor(.gray)
                .onTapGesture {self.isShowCMV = true }
                .sheet(isPresented: self.$isShowCMV) {
                    ComposerMoreView(isShowCMV: self.$isShowCMV, tweetText: self.tweetText)
                }
            
            Divider()
            Text(self.tweetText == "" ? "Tweet" : "Tweet" )
                .foregroundColor(self.tweetText == "" ? .gray : .blue )
                .onTapGesture {
                if self.tweetText != "" {
                    
                    swifter.postTweet(status: self.tweetText, inReplyToStatusID: tweetIDString, autoPopulateReplyMetadata: true, success: {_ in
                        switch self.timeline.type { //如果是在detail视图则不更新timeline
                        case .session:
                            print(#line, self.tweetIDString as Any)
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