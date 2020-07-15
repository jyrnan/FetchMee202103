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
        GeometryReader {
            geometry in
            HStack(spacing:2) {
                VStack(spacing:2) {
                    if self.images["0"] != nil {
                        imageThumb(uiImage: self.images["0"]!)
                    }
                    if self.images["2"] != nil {
                        imageThumb(uiImage: self.images["2"]!)
                    }
                }
                
                VStack(spacing:2) {
                    if self.images["1"] != nil {
                        imageThumb(uiImage: self.images["1"]!)
                    }
                    
                    if self.images["3"] != nil {
                        imageThumb(uiImage: self.images["3"]!)
                    }
                }
            }
            
            .aspectRatio(contentMode: .fill)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
        }
    }
}

struct Images_Previews: PreviewProvider {
    static var previews: some View {
        Images(images: ["0": UIImage(named: "defaultImage")!,
                        "1": UIImage(named: "defaultImage")!,
                        "2": UIImage(named: "defaultImage")!,
                        "3": UIImage(named: "defaultImage")!])
    }
}

struct imageThumb: View {
    @State var presentedImageViewer: Bool = false
    var uiImage: UIImage
    var body: some View {
        Image(uiImage: self.uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .onTapGesture {
                self.presentedImageViewer = true
            }
            .fullScreenCover(isPresented: self.$presentedImageViewer) {
                ImageViewer(image: self.uiImage,presentedImageViewer: $presentedImageViewer)
            }
    }
}
