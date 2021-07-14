//
//  TimelineIcon.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/26.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import Swifter

struct TimelineIcon: View {
    @EnvironmentObject var store: Store
    
    var timeline: AppState.TimelineData.Timeline
    @State var showTimeline: Bool = false
//    var timelineDataBinding: Binding<AppState.TimelineData>  {$store.appState.timelineData}
   
    var body: some View {
        ZStack{
            NavigationLink(destination:TimelineView(timeline: timeline), isActive: $showTimeline, label:{EmptyView()} ).disabled(true)
            
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
                    Text(timeline.type.isList ? "List" : "")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(Color.init(.darkGray))
                        .padding([.leading, .trailing], 8)
                        .padding(.bottom, 0)
                }
                
                HStack {
                    Spacer()
                    Text(timeline.type.rawValue)
                        .font(.callout)
                        .bold()
                        .foregroundColor(Color.gray)
                        .padding(.trailing, 8)
                        .padding(.bottom, 8)
                }
            }
        }
        .frame(width: 92, height: 92, alignment: .center)
        
        .onTapGesture {
            if timeline.tweetIDStrings.isEmpty {
                store.dispatch(.fetchTimeline(timelineType: timeline.type, mode: .top))
            }
            showTimeline = true
        }
        //长按清除新推文数量
        .onLongPressGesture {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            store.dispatch(.updateNewTweetNumber(timelineType: timeline.type, numberOfReadTweet: 200))}
    }
}


struct TimelineIcon_Previews: PreviewProvider {
    static var store = Store.sample
    static var previews: some View {
        TimelineIcon(timeline: store.appState.timelineData.timelines["Mention"]!)
            .environmentObject(store)
    }
}
