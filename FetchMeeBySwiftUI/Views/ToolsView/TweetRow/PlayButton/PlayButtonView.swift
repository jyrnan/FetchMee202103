//
//  PlayButtonView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import AVKit

struct PlayButtonView: View {
    var viewModel: PlayButtonViewModel
   
    @State var playVideo: Bool = false
    @State var player: AVPlayer = AVPlayer()
    
    var body: some View {
        Image(systemName: "play.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 48, height: 48, alignment: .center)
            .foregroundColor(.white).opacity(0.7)
            .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                ForEach(viewModel.contextMenuButtons) {
                    button in
                    Button(action: button.action, label: {
                        Text(button.labelText)
                        Image(systemName: button.labelImage)
                    })
                }
               
            }/*@END_MENU_TOKEN@*/)
            .onTapGesture(count: 1, perform: {

                if self.playVideo {
                    self.player = AVPlayer()
                    self.playVideo = false
                } else {
                    if let url = viewModel.mediaUrlString {
                        self.player = AVPlayer(url: URL(string: url)!)
//                        viewModel.playVideo()
                        self.playVideo = true
                    }
                }
            })
            .fullScreenCover(isPresented: self.$playVideo, onDismiss: {
                self.player = AVPlayer()
//                viewModel.stopPlayVideo()
                
            }, content: {
//                PlayerContainerView(player: self.player)
                VideoPlayView(player: player) //用官方的播放器了
            })
    }
}

struct PlayButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PlayButtonView(viewModel: PlayButtonViewModel(url: ""))
            .preferredColorScheme(.dark)
    }
}
