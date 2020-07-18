//
//  Composer.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct Composer: View {
    @ObservedObject var timeline : Timeline
    @State var tweetText: String = ""
    var tweetIDString: String?
    
//    @Binding var isPresentedAlert: Bool
//    @Binding var alertText: String
    @State var bigEdit: Bool = false
    
    @EnvironmentObject var alerts: Alerts
    
    var body: some View {
        HStack(alignment: .center) {
            TextField("Tweet something here...", text: $tweetText)
                
            Button(self.tweetText == "" ? "Tweet" : "Tweet" ) {
                if self.tweetText != "" {
                    
                    swifter.postTweet(status: self.tweetText, inReplyToStatusID: tweetIDString, autoPopulateReplyMetadata: true, success: {_ in self.timeline.refreshFromTop()
                        print(#line, self.tweetIDString as Any)
                        self.alerts.stripAlert.alertText = "Tweet sent!"
                        self.alerts.stripAlert.isPresentedAlert.toggle()
                        
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
        Composer(timeline: Timeline(type: .home))
    }
}
