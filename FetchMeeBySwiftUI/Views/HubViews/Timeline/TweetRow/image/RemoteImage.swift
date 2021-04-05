//
//  RemoteImage.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/31.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI

struct RemoteImage: View {
    
    var imageUrl: String
    @StateObject var fetcher: RemoteImageFromUrl
    
    init(imageUrl: String) {
        self.imageUrl = imageUrl
        _fetcher = StateObject(wrappedValue: RemoteImageFromUrl(imageUrl: imageUrl, imageType: .thrumb))
            }

    var body: some View {
        Image(uiImage: fetcher.image).resizable()
            .onAppear{fetcher.getImage()}
            
    }
}
