//
//  ComposerMoreView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ComposerMoreView: View {
    @Binding var isShowCMV: Bool
    
    @State var tweetText: String = "Please input something here..."
    
    var body: some View {
        NavigationView {
            VStack {
                if #available(iOS 14.0, *) {
                    TextEditor(text: self.$tweetText)
                        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                } else {
                    // Fallback on earlier versions
                }
                Text(self.tweetText)
                Spacer()
            }
            .navigationTitle("Tweet")
        }
        
        
    }
}

struct ComposerMoreView_Previews: PreviewProvider {
    static var previews: some View {
        ComposerMoreView(isShowCMV: .constant(true))
    }
}
