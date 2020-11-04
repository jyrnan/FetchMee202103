//
//  TimelinesView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct TimelinesView: View {
    
    var body: some View {
        VStack {
            HStack {
                Text("Timeline").font(.caption).bold().foregroundColor(Color.gray)
                Spacer()
            }.padding(.leading,16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    TimelineIconView(type: .home)
                    TimelineIconView(type: .mention)
                    TimelineIconView(type: .favorite)
                    TimelineIconView(type: .message)
                    
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
