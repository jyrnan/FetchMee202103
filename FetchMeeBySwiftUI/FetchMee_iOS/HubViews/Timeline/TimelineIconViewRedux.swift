//
//  TimelineIconViewRedux.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/26.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import Swifter

struct TimelineIconViewRedux: View {
    @EnvironmentObject var store: Store
    
    var timelineType: TimelineType
    var timeline: AppState.TimelineData.Timeline
    {
//        switch timelineType {
//        case .home:
//            return store.appState.timelineData.home
//        case .mention:
//            return  store.appState.timelineData.mention
//        default:
//            return AppState.TimelineData.Timeline()
//        }
        store.getTimeline(timelineType: timelineType)
    }
    
    var body: some View {
        NavigationLink(destination:TimelineViewRedux(timelineType: timelineType)){
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
                        Text("Name")
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
