//
//  ImageThumbView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/26.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ImageThumb: View {
//    @EnvironmentObject var fetcheMee: User
    @EnvironmentObject var alerts: Alerts
    
    @ObservedObject var timeline: Timeline
    var tweetIDString: String
    var index: Int //在tweetMedia中images的第几个
    
    @State var presentedImageViewer: Bool = false
    @State var isImageDownloaded: Bool = true //标记大图是否下载完成
    //    var isSelectMode: Bool = false //控制单击是否作为选择
    
    @StateObject var remoteImageUrl: RemoteImageUrl
    
    var uiImage: UIImage {
//        self.timeline.tweetMedias[tweetIDString]?.images[index] ?? UIImage(named: "defaultImage")!
        
        remoteImageUrl.image
        
        
    } //定义一个计算属性方便后续引用。增加了重点区域识别功能，但是看起来效果不理想
    var width: CGFloat
    var height: CGFloat
    
    init(timeline: Timeline, tweetIDString: String, index: Int, width: CGFloat, height: CGFloat) {
        self.timeline = timeline
        self.tweetIDString = tweetIDString
        self.index = index
        self.width = width
        self.height = height
        
        let url = timeline.tweetMedias[tweetIDString]?.urlStrings?[index] ?? ""
        _remoteImageUrl = StateObject(wrappedValue: RemoteImageUrl(imageUrl: url))
    }
    
    
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
                                alerts.presentedView = AnyView(imageViewer)
                                withAnimation{alerts.isShowingPicture = true}                                }
                            self.isImageDownloaded = true
                            
                        }
                        )}
                    
                    
                }
            
            ActivityIndicator(isAnimating: self.$isImageDownloaded, style: .medium)
        }
    }
}
