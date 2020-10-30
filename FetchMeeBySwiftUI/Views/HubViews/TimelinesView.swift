//
//  TimelinesView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct TimelinesView: View {
    @EnvironmentObject var fetchMee: AppData
    
    var body: some View {
        VStack {
            HStack {
                Text("Timeline").font(.caption).bold().foregroundColor(Color.gray)
                Spacer()
            }.padding(.leading,16)
//            .padding(.top, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    TimelineIconView(timeline: fetchMee.home)
                    TimelineIconView(timeline: fetchMee.mention)
                    TimelineIconView(timeline: fetchMee.favorite)
                    ForEach((fetchMee.users[fetchMee.loginUserID]?.lists.keys.sorted() ?? []), id: \.self) { listName in
                        TimelineIconView(timeline: Timeline(type: .list, listTag: fetchMee.users[fetchMee.loginUserID]?.lists[listName]), listName: listName)
                    }
                    
                    TimelineIconView(timeline: fetchMee.message)
                    
                }.padding(.bottom, 8).padding(.leading, 16)
            }.padding(0)
        }
    }
}

struct TimelinesView_Previews: PreviewProvider {
    static var previews: some View {
        TimelinesView()
    }
}
