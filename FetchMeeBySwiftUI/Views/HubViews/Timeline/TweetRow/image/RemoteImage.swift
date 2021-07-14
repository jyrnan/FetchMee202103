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
    var imageType: RemoteImageFetcher.ImageType
    @StateObject var fetcher: RemoteImageFetcher
    
    init(imageUrl: String, imageType: RemoteImageFetcher.ImageType = .thumrb) {
        self.imageUrl = imageUrl
        self.imageType = imageType
        _fetcher = StateObject(wrappedValue: RemoteImageFetcher(imageUrl: imageUrl, imageType: imageType))
            }

    var body: some View {
        Image(uiImage: fetcher.image)
            .resizable()
            .onAppear{fetcher.getImage()}
            
    }
}
