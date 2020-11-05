//
//  TimelineIconView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

struct TimelineIconView: View {
//    var type: TimelineType = .home
    @StateObject private var timeline: Timeline
    @State var listName: String?
    
    init(type: TimelineType = .home) {
//        self.type = type
        _timeline = StateObject(wrappedValue: Timeline(type: type))
    }
    
    var body: some View {
        NavigationLink(destination:TimelineView(timeline: timeline, listName: listName)){
            ZStack{
                RoundedRectangle(cornerRadius: 18)
                    .frame(width: 92, height: 92, alignment: .center)
                    .foregroundColor(timeline.newTweetNumber == 0 ? Color.init("BackGroundLight") : timeline.type.uiData.themeColor)
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 3)
                    .padding(0)
                
                VStack {
                    HStack {
                        Image(systemName: timeline.type.uiData.iconImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32, alignment: .center)
                            .foregroundColor(timeline.newTweetNumber != 0 ? Color.init("BackGroundLight") : timeline.type.uiData.themeColor)
                        Spacer()
                        Text(timeline.newTweetNumber > 99 ? "99" : "\(timeline.newTweetNumber)").fixedSize()
                            .font(.title)
                            .foregroundColor(timeline.newTweetNumber != 0 ? Color.init("BackGroundLight") : timeline.type.uiData.themeColor)
                    }.padding(6).padding(.trailing, 8)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Text(listName ?? "")
                            .font(.caption2)
                            .bold()
                            .foregroundColor(Color.gray)
                            .padding([.leading, .trailing], 8)
                            .padding(.bottom, 0)
                    }
                    
                    HStack {
                        Spacer()
                        Text(timeline.type.rawValue)
                            .font(.callout)
                            .bold()
                            .foregroundColor(Color.init(.darkGray))
                            .padding(.trailing, 8)
                            .padding(.bottom, 8)
                    }
                }
            }
            .frame(width: 92, height: 92, alignment: .center)
            
        }
    }
}


struct TimelineIconView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            TimelineIconView(type: .home)
        }
        
    }
}
