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
    
    @Binding var presentedModal: Bool
    @State var bigEdit: Bool = false
    
    var body: some View {
        HStack {
            TextField("Tweet here, Press for more...", text: $tweetText)
                
            Button(self.tweetText == "" ? "Tweet" : "Tweet" ) {
                if self.tweetText != "" {
                    
                    swifter.postTweet(status: self.tweetText, inReplyToStatusID: tweetIDString, autoPopulateReplyMetadata: true, success: {_ in self.timeline.refreshFromTop()
                        print(#line, self.tweetIDString as Any)
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
        Composer(timeline: Timeline(type: .home), presentedModal: .constant(true))
    }
}
