//
//  ToolsView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/16.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ToolsView: View {
    @ObservedObject var timeline: Timeline
    var tweetIDString: String
    
    var body: some View {
        VStack {
            HStack{
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "bubble.right")
                })
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "repeat")
                })
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "heart")
                })
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "square.and.arrow.up")
                        
                })
            }.accentColor(.gray)
            Divider()
            Composer(timeline: timeline, tweetIDString: tweetIDString, presentedModal: .constant(true))
            
        }

    }
}

struct ToolsView_Previews: PreviewProvider {
    static var previews: some View {
        ToolsView(timeline: Timeline(type: .home), tweetIDString: "")
            .preferredColorScheme(.light)
    }
}
