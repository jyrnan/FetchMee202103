//
//  TimelinesView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct TimelinesView: View {
    @EnvironmentObject var user: User
    
    var body: some View {
        VStack {
            HStack {
                Text("Timeline").font(.caption).bold().foregroundColor(Color.gray)
                Spacer()
            }.padding(.leading,16).padding(.top, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    TimelineIconView(timeline: user.home)
                    TimelineIconView(timeline: user.mention)
                    TimelineIconView(timeline: user.message)
                    ForEach(user.myInfo.lists.keys.sorted(), id: \.self) { listName in
                        TimelineIconView(timeline: Timeline(type: .list, listTag: user.myInfo.lists[listName]), listName: listName)
                    }
                    
                }.padding(.top, 8).padding(.bottom, 8).padding(.leading, 16)
            }.padding(0)
        }
    }
}

struct TimelinesView_Previews: PreviewProvider {
    static var previews: some View {
        TimelinesView()
    }
}
