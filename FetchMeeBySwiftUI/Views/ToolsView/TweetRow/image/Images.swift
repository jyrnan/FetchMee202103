//
//  Images.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct Images: View {
    @EnvironmentObject var alerts: Alerts

    var imageUrlStrings: [String]
    
    @State var presentedImageViewer: Bool = false
    
    var body: some View {
        return containedView()
    }
    
    func containedView() -> AnyView {
        switch imageUrlStrings.count {
        case 1:
            return AnyView(GeometryReader {
                geometry in
                HStack {
                    ImageThumb(imageUrl: imageUrlStrings[0],
                               width: geometry.size.width, height: geometry.size.height)
                }
            })
            
        case 2:
            return AnyView(GeometryReader {
                geometry in
                HStack(spacing:2) {
                    ImageThumb(imageUrl: imageUrlStrings[0], width: geometry.size.width / 2, height: geometry.size.height)
                    ImageThumb(imageUrl: imageUrlStrings[1], width: geometry.size.width / 2, height: geometry.size.height)
                }
            })
        case 3:
            return AnyView(GeometryReader {
                geometry in
                HStack(spacing:2) {
                    VStack(spacing:2) {
                        ImageThumb(imageUrl: imageUrlStrings[0], width: geometry.size.width / 2, height: geometry.size.height / 2)
                        ImageThumb(imageUrl: imageUrlStrings[2], width: geometry.size.width / 2, height: geometry.size.height / 2)
                    }
                    ImageThumb(imageUrl: imageUrlStrings[1], width: geometry.size.width / 2, height: geometry.size.height)
                }
            })
        default:
            return AnyView(GeometryReader {
                geometry in
                HStack(spacing:2) {
                    
                    VStack(spacing:2) {
                        ImageThumb(imageUrl: imageUrlStrings[0], width: geometry.size.width / 2, height: geometry.size.height / 2)
                        ImageThumb(imageUrl: imageUrlStrings[2], width: geometry.size.width / 2, height: geometry.size.height / 2)
                    }
                    VStack(spacing:2) {
                        ImageThumb(imageUrl: imageUrlStrings[1], width: geometry.size.width / 2, height: geometry.size.height / 2)
                        ImageThumb(imageUrl: imageUrlStrings[3], width: geometry.size.width / 2, height: geometry.size.height / 2)
                    }
                }
            })
        }
    }
}


struct Images_Previews: PreviewProvider {
    static var timeline = Timeline(type: .home)
    static var tweetIDString = "0000"
    static var previews: some View {
        Images(imageUrlStrings: [])
    }
}



