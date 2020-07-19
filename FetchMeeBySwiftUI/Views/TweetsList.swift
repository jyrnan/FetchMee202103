//
//  Homeline.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

enum TweetListType: String {
    case home = "Home"
    case mention = "Mentions"
    case list
    case user
    case session
}

struct TweetsList: View {
    @ObservedObject var timeline: Timeline
//    @ObservedObject var replySession: Timeline = Timeline(type: .session)
    
    @State var presentedModal: Bool = false //用于标志是否显示ModalView，例如Composer
    @State var isShowDetail: Bool = false
    @State var isFirstRun: Bool = true //设置用于第一次运行的时候标志
    
    var tweetListType: TweetListType 
    
    var body: some View {
        
        return
            containedView()
        
    }
    func containedView() -> AnyView {
        switch tweetListType {
        case .home:
            return  AnyView(ForEach(self.timeline.tweetIDStrings, id: \.self) {
                tweetIDString in
                TweetRow(timeline: timeline, tweetIDString: tweetIDString)
                    
            }
            .onDelete { indexSet in
                print()}
            .onMove { indecies, newOffset in
                print()
            }
//            .listRowBackground(Color.blue.opacity(0.5))
            )
        case .mention:
            return AnyView(ForEach(self.timeline.tweetIDStrings, id: \.self) {
                tweetIDString in
                ZStack {
                    MentionRow(timeline: timeline, tweetIDString: tweetIDString)
                }
            })
        default:
            return AnyView(EmptyView())
        }
    }
}

struct TweetsList_Previews: PreviewProvider {
    static var previews: some View {
        //        TweetsList(timeline: Timeline())
        Text("hello")
    }
}
