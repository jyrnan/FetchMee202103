//
//  Images.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct Images: View {
    @ObservedObject var timeline: Timeline
    var tweetIDString: String
//    @State var images: [String: UIImage]
    
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
                    ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, number: 0, width: geometry.size.width, height: geometry.size.height)
                }
            })
            
        case 2:
            return AnyView(GeometryReader {
                geometry in
                HStack(spacing:2) {
                    ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, number: 0, width: geometry.size.width / 2, height: geometry.size.height)
                    ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, number: 1, width: geometry.size.width / 2, height: geometry.size.height)
                }
            })
        case 3:
            return AnyView(GeometryReader {
                geometry in
                HStack(spacing:2) {
                    VStack(spacing:2) {
                        ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, number: 0, width: geometry.size.width / 2, height: geometry.size.height / 2)
                        ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, number: 2, width: geometry.size.width / 2, height: geometry.size.height / 2)
                    }
                    ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, number: 1, width: geometry.size.width / 2, height: geometry.size.height)
                }
            })
        default:
            return AnyView(GeometryReader {
                geometry in
                HStack(spacing:2) {
                    
                    VStack(spacing:2) {
                        ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, number: 0, width: geometry.size.width / 2, height: geometry.size.height / 2)
                        ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, number: 2, width: geometry.size.width / 2, height: geometry.size.height / 2)
                    }
                    VStack(spacing:2) {
                        ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, number: 1, width: geometry.size.width / 2, height: geometry.size.height / 2)
                        ImageThumb(timeline: self.timeline, tweetIDString: self.tweetIDString, number: 3, width: geometry.size.width / 2, height: geometry.size.height / 2)
                    }
                }
            })
        }
    }
}

//struct Images_Previews: PreviewProvider {
//    var timeline = Timeline(type: .home)
//    var tweetIDString = "0000"
//    static var previews: some View {
//        Images(timeline: timeline, tweetIDString: tweetIDString, images: ["0": UIImage(named: "Test")!,
//                        "1": UIImage(named: "defaultImage")!,
//                        "2": UIImage(named: "Test")!,
//                        "3": UIImage(named: "Test")!]).frame(height: 160)
//    }
//}

struct ImageThumb: View {
    @ObservedObject var timeline: Timeline
    var tweetIDString: String
    var number: Int
    
    @State var presentedImageViewer: Bool = false
//    var uiImage: UIImage
    var width: CGFloat
    var height: CGFloat
    var body: some View {
        ZStack(alignment: .center) {
            if #available(iOS 14.0, *) {
                Image(uiImage: (self.timeline.tweetMedias[tweetIDString]?.images[String(number)]!)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height, alignment: .center) //直接按照传入的大小进行图片调整。
                    .clipped()
                    .contentShape(Rectangle()) //可以定义触控的内容区域，并在此基础上进行触控，也就是触控的区域。完美解决bug
                    .onTapGesture {
                        if let urlString = self.timeline.tweetMedias[self.tweetIDString]?.urlStrings![number] {
                        self.timeline.imageDownloaderWithClosure(from: urlString + ":large", sh: { im in
                            self.timeline.tweetMedias[self.tweetIDString]?.images[String(number)] = im
                            self.presentedImageViewer = true
                        } )}
                        
                    }
                    .fullScreenCover(isPresented: self.$presentedImageViewer) {
                        ImageViewer(image: (self.timeline.tweetMedias[tweetIDString]?.images[String(number)]!)!,presentedImageViewer: $presentedImageViewer)
                    }
                    
            } else {
                // Fallback on earlier versions
            }
            
            //            Text(" ") //提供触摸的区域的实现，但是会增加运算，待优化
            //                .frame(width: width, height: height, alignment: .center)
            //                .background(Color.white.opacity(0.01))
            
        }
        
    }
}
