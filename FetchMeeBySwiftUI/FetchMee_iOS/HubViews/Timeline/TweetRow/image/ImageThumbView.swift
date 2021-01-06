//
//  ImageThumbView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/26.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

import KingfisherSwiftUI
import class Kingfisher.KingfisherManager
import protocol Kingfisher.ImageProcessor
import enum Kingfisher.ImageProcessItem
import struct Kingfisher.KingfisherParsedOptionsInfo
//import Kingfisher

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
//            KFImage(URL(string: imageUrl + ":small")!,
//                    options: [.processor(WebpProcessor())])

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
                .onAppear{
                    remoteImageFromUrl.getImage()
                }
            
            ActivityIndicator(isAnimating: self.$isImageDownloaded, style: .medium)
        }
    }
    
    
}

//struct WebpProcessor: ImageProcessor {
//
//    // `identifier` should be the same for processors with the same properties/functionality
//    // It will be used when storing and retrieving the image to/from cache.
//    let identifier = "com.jyrnan.webpprocessor"
//
//    // Convert input data/image to target image and return it.
//    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> UIImage? {
//        switch item {
//        case .image(let image):
//            print("already an image")
//            return image.detectFaces{result in
//                var image = image
//                DispatchQueue.main.async {
//                    image =  (result?.cropByFace(image))!
//                    _ = result?.drawnOn(image)
//                    print(#line, #file, "face process")
//                }
//                return image
//                      }
//
//
//        case .data(let data):
////            return WebpFramework.createImage(from: webpData)
//        return UIImage(data: data)
//        }
//    }
//}
