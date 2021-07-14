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
    @EnvironmentObject var store: Store
    
    @State var presentedImageViewer: Bool = false
    @State var isImageDownloaded: Bool = true //标记大图是否下载完成
    
    var imageUrl: String
    var width: CGFloat
    var height: CGFloat
    //MARK:-Functions
    
    var body: some View {
        ZStack(alignment: .center) {

                RemoteImage(imageUrl: imageUrl)
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height, alignment: .center) //直接按照传入的大小进行图片调整。
                .clipped()
                .contentShape(Rectangle()) //可以定义触控的内容区域，并在此基础上进行触控，也就是触控的区域。完美解决bug
                .onTapGesture {
                    ///点击下载原图并调用imageViewer
                    isImageDownloaded = false
                    RemoteImageFetcher.imageDownloaderWithClosure(imageUrl: imageUrl + ":large") {image in
                        ///下载完成后调用imageViewer
                        DispatchQueue.main.async {
                            let imageViewer = ImageViewer(image: image)
                            withAnimation{
                            store.dispatch(.showImageViewer(view: imageViewer))
                        }
                            
                    }
                        self.isImageDownloaded = true}}
                ActivityIndicator(isAnimating: self.$isImageDownloaded, style: .medium)
        }
    }
}


struct ImageThumbView_Previews: PreviewProvider {
    static var previews: some View {
        ImageThumb(imageUrl: "https://imgconvert.csdnimg.cn/aHR0cHM6Ly91cGxvYWQtaW1hZ2VzLmppYW5zaHUuaW8vdXBsb2FkX2ltYWdlcy80MTA4NS04ODVhYmJjMTNiNWYwMzk5LmpwZw?x-oss-process=image/format,png", width: 200, height: 100)
    }
}
