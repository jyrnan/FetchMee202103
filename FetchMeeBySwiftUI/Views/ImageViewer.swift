//
//  ImageViewer.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ImageViewer: View {
    var image: UIImage
    @Binding var presentedImageViewer: Bool
    
    @State var scale: CGFloat = 1
    @State var isButtonHidden: Bool = false
   
    var body: some View {
        VStack {
            if !self.isButtonHidden {
                Button("Close") {
                    self.presentedImageViewer = false
                }
            }
            
//            ScrollView {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(self.scale)
                    .gesture(MagnificationGesture().onChanged({scale in
                        self.scale = scale.magnitude
                    }).onEnded({
                        scaleFinal in
                        self.scale = scaleFinal.magnitude
                    }))
                    
                    .edgesIgnoringSafeArea(.all)
//            }
        }
    }
}

struct ImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewer(image: UIImage(named: "defaultImage")!, presentedImageViewer: .constant(true))
    }
}
