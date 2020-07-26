//
//  TweetTextView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/26.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

struct TweetTextView: View {
    var tweetText: [String] = ["hello", "#world!", "Nice"]
    
    var body: some View {
        Group {
            () -> AnyView in
            guard self.tweetText.count > 1 else {
                return AnyView(Text(self.tweetText.first ?? "")
                                .foregroundColor(self.tweetText.first?.first == "#" ? .blue : .primary))
            }
            //手动把字符串组第一个设置成初始View，然后开始循环添加后续的字串，可以避免多添加一个空格
            var textView = Text(self.tweetText.first!)
                .foregroundColor(self.tweetText.first?.first == "#" ? .blue : .primary)
            
            for string in self.tweetText.dropFirst() {
                textView = textView
                + Text(" ")
                + Text(string)
                    .foregroundColor(string.first == "#" ? .blue : .primary)
            }
//            var textView = Text("")
//            for string in self.tweetText {
//                textView = textView
//                + Text(string)
//                    .foregroundColor(string.first == "#" ? .blue : .primary)
//                + Text(" ")
//            }
           return AnyView(textView)
        }
        
    }
}

struct TweetTextView_Previews: PreviewProvider {
    static var previews: some View {
        TweetTextView()
    }
}
