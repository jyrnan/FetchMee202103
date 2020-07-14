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
}

struct TweetsList: View {
    @ObservedObject var timeline: Timeline
    
    @State var presentedModal: Bool = false //用于标志是否显示ModalView，例如Composer
    
    @State var isFirstRun: Bool = true //设置用于第一次运行的时候标志
    
    var tweetListType: TweetListType 
    
    var body: some View {
        
        return
            containedView()
    }
    func containedView() -> AnyView {
        switch tweetListType {
        case .home:
            return  AnyView(ForEach(self.timeline.tweetIdStrings, id: \.self) {
                    tweetIDString in
                    ZStack {
                        TweetRow(tweetMedia: self.timeline.tweetMedias[tweetIDString]!)
                        NavigationLink(destination: DetailView()) {
                            EmptyView()
                            Spacer()
                    }
                }
            })
        case .mention:
            return AnyView(ForEach(self.timeline.tweetIdStrings, id: \.self) {
                    tweetIDString in
                    ZStack {
                        MentionRow(tweetMedia: self.timeline.tweetMedias[tweetIDString]!)
                        NavigationLink(destination: DetailView()) {
                            EmptyView()
                            Spacer()
                    }
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
