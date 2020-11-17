//
//  TimelinesView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter

struct TimelinesView: View {
    
    var lists: [String: ListTag]
    
    var body: some View {
        VStack {
            HStack {
                Text("Timeline").font(.caption).bold().foregroundColor(Color.gray)
                Spacer()
            }.padding(.leading,16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    TimelineIconView(type: .home)
                    TimelineIconView(type: .mention)
                    TimelineIconView(type: .favorite)
                    
                
                    ForEach(lists.keys.sorted(), id: \.self) {listName in
                        TimelineIconView(type: .list, listName: listName, listTag:lists[listName])
                    }
                    
//                    TimelineIconView(type: .message)
                    
                }
                .padding(.bottom, 8).padding(.leading, 16)
            }
            .padding(0)
        }
    }
}

struct TimelinesView_Previews: PreviewProvider {
    static var previews: some View {
        TimelinesView(lists: [:])
    }
}
