//
//  ImageThumbView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/26.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ImageThumb: View {
    //MARK:-Properties
    @EnvironmentObject var alerts: Alerts
    @State var presentedImageViewer: Bool = false
    @State var isImageDownloaded: Bool = true //标记大图是否下载完成
    
    var imageUrl: String
    @StateObject var remoteImageFromUrl: RemoteImageFromUrl
    
    var width: CGFloat
    var height: CGFloat
    
    //MARK:-Functions
    
    init(imageUrl: String, width: CGFloat, height: CGFloat) {
        
        self.imageUrl = imageUrl
        
        self.width = width
        self.height = height
        
        _remoteImageFromUrl = StateObject(wrappedValue: RemoteImageFromUrl(imageUrl: imageUrl))
    }
    
    
    var body: some View {
        ZStack(alignment: .center) {
            
            Image(uiImage: remoteImageFromUrl.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height, alignment: .center) //直接按照传入的大小进行图片调整。
                .clipped()
                .contentShape(Rectangle()) //可以定义触控的内容区域，并在此基础上进行触控，也就是触控的区域。完美解决bug
                .onTapGesture {
                    ///点击下载原图并调用imageViewer
                    isImageDownloaded = false
                    RemoteImageFromUrl.imageDownloaderWithClosure(imageUrl: imageUrl + ":large") {image in
                        ///下载完成后调用imageViewer
                        DispatchQueue.main.async {
                            let imageViewer = ImageViewer(image: image)
                            alerts.presentedView = AnyView(imageViewer)
                            withAnimation{alerts.isShowingPicture = true}                                }
                        self.isImageDownloaded = true}}
            
            
            ActivityIndicator(isAnimating: self.$isImageDownloaded, style: .medium)
        }
    }
}
