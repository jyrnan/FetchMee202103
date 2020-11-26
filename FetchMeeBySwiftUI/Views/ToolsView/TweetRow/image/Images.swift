//
//  Images.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct Images: View {
//    @EnvironmentObject var fetchMee: User
    @EnvironmentObject var alerts: Alerts
    
    @ObservedObject var timeline: Timeline
    var tweetIDString: String
    
    @State var presentedImageViewer: Bool = false
    
    var body: some View {
        return containedView()
    }
    
    func containedView() -> AnyView {
        switch self.timeline.tweetMedias[tweetIDString]?.images.count {
        case 1:
            return AnyView(GeometryReader {
                geometry in
                HStack {
                    ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, index: 0, width: geometry.size.width, height: geometry.size.height)
                }
            })
            
        case 2:
            return AnyView(GeometryReader {
                geometry in
                HStack(spacing:2) {
                    ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, index: 0, width: geometry.size.width / 2, height: geometry.size.height)
                    ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, index: 1, width: geometry.size.width / 2, height: geometry.size.height)
                }
            })
        case 3:
            return AnyView(GeometryReader {
                geometry in
                HStack(spacing:2) {
                    VStack(spacing:2) {
                        ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, index: 0, width: geometry.size.width / 2, height: geometry.size.height / 2)
                        ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, index: 2, width: geometry.size.width / 2, height: geometry.size.height / 2)
                    }
                    ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, index: 1, width: geometry.size.width / 2, height: geometry.size.height)
                }
            })
        default:
            return AnyView(GeometryReader {
                geometry in
                HStack(spacing:2) {
                    
                    VStack(spacing:2) {
                        ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, index: 0, width: geometry.size.width / 2, height: geometry.size.height / 2)
                        ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, index: 2, width: geometry.size.width / 2, height: geometry.size.height / 2)
                    }
                    VStack(spacing:2) {
                        ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, index: 1, width: geometry.size.width / 2, height: geometry.size.height / 2)
                        ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, index: 3, width: geometry.size.width / 2, height: geometry.size.height / 2)
                    }
                }
            })
        }
    }
}


struct Images_Previews: PreviewProvider {
    static var timeline = Timeline(type: .home)
    static var tweetIDString = "0000"
    static var previews: some View {
        Images(timeline: self.timeline, tweetIDString: self.tweetIDString)
    }
}



