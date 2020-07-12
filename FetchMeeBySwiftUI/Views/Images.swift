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
    var body: some View {
        GeometryReader {
            geometry in
            HStack(spacing:1) {
                VStack(spacing:1) {
                if self.images["0"] != nil {
                   
                        Image(uiImage: self.images["0"]!)
                                               .resizable()
                                           .aspectRatio(contentMode: .fill)
//                            .onLongPressGesture {
//                                self.sheet(isPresented: .constant(true), content: {ImageViewer()})
//                    }
                }
                
                if self.images["2"] != nil {
                    
                    Image(uiImage: self.images["2"]!)
                        .resizable()
                       .aspectRatio(contentMode: .fill)
                }
            }
            
            VStack(spacing:1) {
                if self.images["1"] != nil {
                    Image(uiImage: self.images["1"]!)
                        .resizable()
                       .aspectRatio(contentMode: .fill)
                    
                    
                    if self.images["3"] != nil {
                        Image(uiImage: self.images["3"]!)
                            .resizable()
                        .aspectRatio(contentMode: .fill)
                    }
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
