//
//  ImageThumbView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/26.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

//import KingfisherSwiftUI
//import class Kingfisher.KingfisherManager
//import protocol Kingfisher.ImageProcessor
//import enum Kingfisher.ImageProcessItem
//import struct Kingfisher.KingfisherParsedOptionsInfo
//import struct Kingfisher.KingfisherOptionsInfo
//import enum Kingfisher.KingfisherOptionsInfoItem
//import struct Kingfisher.AnyImageModifier
import Kingfisher

struct ImageThumb: View {
    //MARK:-Properties
    @EnvironmentObject var store: Store
    
    @State var presentedImageViewer: Bool = false
    @State var isImageDownloaded: Bool = true //标记大图是否下载完成
    
    var imageUrl: String
    //    @StateObject var remoteImageFromUrl: RemoteImageFromUrl
    //    @State var image: UIImage = UIImage(named: "defaultImage")!
    
    var width: CGFloat
    var height: CGFloat
    //MARK:-Functions
    
    init(imageUrl: String, width: CGFloat, height: CGFloat) {
        
        self.imageUrl = imageUrl
        
        self.width = width
        self.height = height
        //        self.imageModifer = AnyImageModifier(modify: dectectFaceAndSetImageValue)
        
        //        _remoteImageFromUrl = StateObject(wrappedValue: RemoteImageFromUrl(imageUrl: imageUrl))
    }
    
    
    var body: some View {
        ZStack(alignment: .center) {
            
            //            Image(uiImage: remoteImageFromUrl.image)
            //            Image(uiImage: image)
            KFImage(URL(string:imageUrl + ":small")!
//                    options: [.imageModifier(AnyImageModifier(modify:dectectFaceAndSetImageValue ))]
            )
            .placeholder{Image("defaultImage").resizable()}.cancelOnDisappear(true)
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
                        store.dipatch(.showImageViewer(view: AnyView(imageViewer)))
                    }
                    self.isImageDownloaded = true}}
            .onAppear{
                //                    remoteImageFromUrl.getImage()
                //                    RemoteImageFromUrl.imageDownloaderWithClosure(imageUrl: imageUrl, sh: {image in
                //                        DispatchQueue.main.async {
                //                            self.image = image
                //                        }
                //                    })
            }
            
            ActivityIndicator(isAnimating: self.$isImageDownloaded, style: .medium)
        }
    }
    /// 识别图片中的人像，如果有人像则按照人像优化裁剪
    /// 将识别后到image设定到被观察值
    /// - Parameter d: 图像文件的数据
    func dectectFaceAndSetImageValue(_ image: UIImage) -> UIImage {
        var resutlImage: UIImage = image
        image.detectFaces {result in
            if let croppedImage = result?.cropByFace(image) {
                resutlImage = croppedImage
            }
            _ = result?.drawnOn(image)
            //                self.setImage(croppedImage)
            
            //                if result?.count == 1 {print(#line," Detected face!")}
        }
        return resutlImage
    }
}

extension ImageThumb {
    
}


