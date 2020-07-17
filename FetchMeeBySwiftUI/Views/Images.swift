//
//  Images.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct Images: View {
    var images: [String: UIImage]
    
    @State var presentedImageViewer: Bool = false
    
    var body: some View {
        return containedView()
        
        //        GeometryReader {
        //            geometry in
        //            HStack(spacing:2) {
        //                VStack(spacing:2) {
        //                    if self.images["0"] != nil {
        //                        imageThumb(uiImage: self.images["0"]!)
        //                    }
        //                    if self.images["2"] != nil {
        //                        imageThumb(uiImage: self.images["2"]!)
        //                            .frame(height: geometry.size.height / 2)
        //                    }
        //                }
        //                VStack(spacing:2) {
        //                    if self.images["1"] != nil {
        //                        imageThumb(uiImage: self.images["1"]!)
        //                            .frame(width: geometry.size.width / 2)
        //                    }
        //
        //                    if self.images["3"] != nil {
        //                        imageThumb(uiImage: self.images["3"]!)
        //                            .frame(height: geometry.size.height / 2)
        //                    }
        //                }
        //            }
        ////            .frame(width: geometry.size.width, height: geometry.size.height)
        ////            .aspectRatio(contentMode: .fill)
        //            .background(Color.black)
        //        }
    }
    
    func containedView() -> AnyView {
        switch self.images.count {
        case 1:
            return AnyView(GeometryReader {
                geometry in
                            ImageThumb(uiImage: self.images["0"]!, width: geometry.size.width, height: geometry.size.height)})
            
        case 2:
            return AnyView(GeometryReader {
                geometry in
                HStack(spacing:2) {
                    ImageThumb(uiImage: self.images["0"]!, width: geometry.size.width / 2, height: geometry.size.height)
                    ImageThumb(uiImage: self.images["1"]!, width: geometry.size.width / 2, height: geometry.size.height)
                }
            })
        case 3:
            return AnyView(GeometryReader {
                geometry in
                HStack(spacing:2) {
                    VStack(spacing:2) {
                        ImageThumb(uiImage: self.images["0"]!, width: geometry.size.width / 2, height: geometry.size.height / 2)
                        ImageThumb(uiImage: self.images["2"]!, width: geometry.size.width / 2, height: geometry.size.height / 2)
                    }
                    ImageThumb(uiImage: self.images["1"]!, width: geometry.size.width / 2, height: geometry.size.height)
                }
            })
        default:
            return AnyView(GeometryReader {
                geometry in
                HStack(spacing:2) {
                    
                    VStack(spacing:2) {
                        ImageThumb(uiImage: self.images["0"]!, width: geometry.size.width / 2, height: geometry.size.height / 2)
                        ImageThumb(uiImage: self.images["2"]!, width: geometry.size.width / 2, height: geometry.size.height / 2)
                    }
                    VStack(spacing:2) {
                        ImageThumb(uiImage: self.images["1"]!, width: geometry.size.width / 2, height: geometry.size.height / 2)
                        ImageThumb(uiImage: self.images["3"]!, width: geometry.size.width / 2, height: geometry.size.height / 2)
                    }
                }
            })
        }
    }
}

struct Images_Previews: PreviewProvider {
    static var previews: some View {
        Images(images: ["0": UIImage(named: "Test")!,
                        "1": UIImage(named: "defaultImage")!,
                        "2": UIImage(named: "Test")!,
                        "3": UIImage(named: "Test")!]).frame(height: 160)
    }
}

struct ImageThumb: View {
    @State var presentedImageViewer: Bool = false
    var uiImage: UIImage
    var width: CGFloat
    var height: CGFloat
    var body: some View {
        Image(uiImage: self.uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipped()
            .onTapGesture {
                self.presentedImageViewer = true
            }
            .fullScreenCover(isPresented: self.$presentedImageViewer) {
                ImageViewer(image: self.uiImage,presentedImageViewer: $presentedImageViewer)
            }
    }
}
