//
//  TimelineIconView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct TimelineIconView: View {
    @ObservedObject var timeline: Timeline
    
    var body: some View {
        NavigationLink(
            destination: TimelineView(timeline: timeline)){
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
                            .frame(width: 32, height: 32, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .foregroundColor(timeline.newTweetNumber != 0 ? Color.init("BackGroundLight") : timeline.type.uiData.themeColor)
                        Spacer()
                        Text(timeline.newTweetNumber > 99 ? "99" : "\(timeline.newTweetNumber)").fixedSize()
                            .font(.title)
                            .foregroundColor(timeline.newTweetNumber != 0 ? Color.init("BackGroundLight") : timeline.type.uiData.themeColor)
                    }.padding(8).padding(.trailing, 8)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Text(timeline.type.rawValue)
                            .font(.caption)
                            .bold()
                            .foregroundColor(Color.init(.darkGray))
                            .padding(.trailing)
                            .padding(.bottom, 8)
                    }
                }
            }
            .frame(width: 92, height: 92, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}


struct TimelineIconView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            TimelineIconView(timeline: Timeline(type: .home))
            TimelineIconView(timeline: Timeline(type: .list))
        }
        
    }
}
