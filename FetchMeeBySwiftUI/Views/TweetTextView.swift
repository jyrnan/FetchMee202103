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
            var textView = Text("").foregroundColor(.primary)
            for string in self.tweetText {
                textView = textView
                    + Text(" ")
                + Text(string)
                    .foregroundColor(string.first == "#" ? .blue : .primary)
            }
            
           return AnyView(textView)
        }
        
    }
}

struct TweetTextView_Previews: PreviewProvider {
    static var previews: some View {
        TweetTextView()
    }
}
