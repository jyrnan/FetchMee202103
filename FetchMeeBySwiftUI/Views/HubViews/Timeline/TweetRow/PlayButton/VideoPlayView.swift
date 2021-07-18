//
//  VideoPlayView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/8/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import AVKit
import MobileCoreServices

///官方iOS14支持播放器
struct VideoPlayView: View {
    @Environment(\.presentationMode) var presentationMode
    let url:String
    
    var body: some View {
        ZStack{
            VideoPlayer(player: AVPlayer(url: URL(string: url)!))
                .gesture(DragGesture()
                            .onChanged{value in
                                if value.translation.height > 70 {
                                    presentationMode.wrappedValue.dismiss()
                                }
                                                })
        }
    }
}
