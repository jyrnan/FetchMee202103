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
    
    @EnvironmentObject var store: Store
    
//    var lists: [String: String] {store.appState.setting.lists}
    
    var body: some View {
        VStack {
            HStack {
                Text("Timeline").font(.caption).bold().foregroundColor(Color.gray)
                Spacer()
            }.padding(.leading,16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    TimelineIcon(timeline: store.appState.timelineData.getTimeline(timelineType: .home))
                    TimelineIcon(timeline: store.appState.timelineData.getTimeline(timelineType: .mention))
                    TimelineIcon(timeline: store.appState.timelineData.getTimeline(timelineType: .favorite))
                
                    ForEach(store.appState.setting.lists.keys.sorted(), id: \.self) {id in
                        TimelineIcon( timeline: store.appState.timelineData.getTimeline(timelineType: .list(id:id, listName: store.appState.setting.lists[id]! )))
                    }
                    
                    
                }
                .padding(.bottom, 8).padding(.leading, 16)
            }
            .padding(0)
        }
    }
}

struct TimelinesView_Previews: PreviewProvider {
    static var previews: some View {
        TimelinesView().environmentObject(Store())
    }
}
