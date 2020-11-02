//
//  Images.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct Images: View {
    @EnvironmentObject var fetchMee: AppData
    
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

struct ImageThumb: View {
    @EnvironmentObject var fetcheMee: AppData
    
    @ObservedObject var timeline: Timeline
    var tweetIDString: String
    var index: Int //在tweetMedia中images的第几个
    
    @State var presentedImageViewer: Bool = false
    @State var isImageDownloaded: Bool = true //标记大图是否下载完成
    //    var isSelectMode: Bool = false //控制单击是否作为选择
    
    
    var uiImage: UIImage {
        self.timeline.tweetMedias[tweetIDString]?.images[index] ?? UIImage(named: "defaultImage")!
        
    } //定义一个计算属性方便后续引用。增加了重点区域识别功能，但是看起来效果不理想
    var width: CGFloat
    var height: CGFloat
    var body: some View {
        ZStack(alignment: .center) {
            
            Image(uiImage: self.uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height, alignment: .center) //直接按照传入的大小进行图片调整。
                .clipped()
                .contentShape(Rectangle()) //可以定义触控的内容区域，并在此基础上进行触控，也就是触控的区域。完美解决bug
                .onTapGesture {
                    if let urlString = self.timeline.tweetMedias[self.tweetIDString]?.urlStrings![index] {
                        self.isImageDownloaded = false
                        self.timeline.imageDownloaderWithClosure(from: urlString + ":large", sh: { im in
                            DispatchQueue.main.async {
                                self.timeline.tweetMedias[self.tweetIDString]?.images[index] = im
                                let imageViewer = ImageViewer(image: im)
                                fetcheMee.presentedView = AnyView(imageViewer)
                                withAnimation{fetcheMee.isShowingPicture = true}                                }
                            self.isImageDownloaded = true
                            
                        }
                        )}
                    
                    
                }
            
            ActivityIndicator(isAnimating: self.$isImageDownloaded, style: .medium)
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
