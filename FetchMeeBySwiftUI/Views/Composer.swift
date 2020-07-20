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
    var tweetIDString: String?
    
    @State var bigEdit: Bool = false
    
    @Binding var someToggle: Bool //供灵活使用的触发器值。例如在detailview里面用来传递是否关闭detailView本身的触发值
    
    var body: some View {
        HStack(alignment: .center) {
            TextField("Tweet something here...", text: $tweetText)
            Divider()
            Button(self.tweetText == "" ? "Tweet" : "Tweet" ) {
                if self.tweetText != "" {
                    
                    swifter.postTweet(status: self.tweetText, inReplyToStatusID: tweetIDString, autoPopulateReplyMetadata: true, success: {_ in
                        switch self.timeline.type { //如果是在detail视图则不更新timeline
                        case .session:
                            print()
                        default:
                            self.timeline.refreshFromTop()
                        }
                        print(#line, self.tweetIDString as Any)
                        self.someToggle = false //
                        self.alerts.stripAlert.alertText = "Tweet sent!"
                        self.alerts.stripAlert.isPresentedAlert = true
                           
                    })
                    self.tweetText = ""
                    self.hideKeyboard()
                    
                } else {
                    print(#line, "nothing")
                }
            }.disabled(self.tweetText == "")
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
        Composer(timeline: Timeline(type: .home), someToggle: .constant(true))
    }
}
