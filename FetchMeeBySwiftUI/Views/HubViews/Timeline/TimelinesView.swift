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
    
//    var timelines: [String : AppState.TimelineData.Timeline] = [:]
   
    var body: some View {
        VStack {
            HStack {
                Text("Timeline").font(.caption).bold().foregroundColor(Color.gray)
                Spacer()
            }.padding(.leading,16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
//                    TimelineIcon(timeline: timelines["Home"]!)
                    TimelineIcon(timeline: store.appState.timelineData.getTimeline(timelineType: .home))
                    TimelineIcon(timeline: store.appState.timelineData.getTimeline(timelineType: .mention))
                    TimelineIcon(timeline: store.appState.timelineData.getTimeline(timelineType: .favorite))

                    ForEach(store.appState.setting.lists
                                .map{($0.key, $0.value)}
                                .sorted{$0.1 < $1.1},
                            id: \.0) {id, name in
                        TimelineIcon( timeline: store.appState.timelineData.getTimeline(timelineType: .list(id:id, listName: name )))
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
