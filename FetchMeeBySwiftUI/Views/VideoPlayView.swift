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

//struct PlayerView: UIViewRepresentable {
//    var url: String?
//  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
//    (uiView as? PlayerUIView)?.updatePlayer(player: player)
//  }
//  func makeUIView(context: Context) -> UIView {
//    return PlayerUIView(frame: .zero, url: self.url)
//  }
//}
//
//class PlayerUIView: UIView {
//  private let playerLayer = AVPlayerLayer()
//    init(frame: CGRect, url: String?) {
//        super.init(frame: frame)
//
//    let url = URL(string: url!)!
//    let player = AVPlayer(url: url)
//    player.play()
//
//    playerLayer.player = player
//    layer.addSublayer(playerLayer)
//  }
//  required init?(coder: NSCoder) {
//   fatalError("init(coder:) has not been implemented")
//  }
//
//  override func layoutSubviews() {
//    super.layoutSubviews()
//    playerLayer.frame = bounds
//  }
//
//    func updatePlayer(player: AVPlayer) {
//        self.playerLayer.player = player
//    }
//}

///官方iOS14支持播放器
struct VideoPlayView: View {
    @Environment(\.presentationMode) var presentationMode
    let player: AVPlayer
    
    var body: some View {
        VideoPlayer(player: player)
        Text("Close")
            .padding(4)
            .foregroundColor(.white)
            .background(Color.accentColor)
            .clipShape(Capsule())
            .onTapGesture {
                presentationMode.wrappedValue.dismiss()
            }
    }
}

struct videoPlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerContainerView(player: AVPlayer())
    }
}

///利用普通代码
struct PlayerView: UIViewRepresentable {
    let player: AVPlayer
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
        (uiView as? PlayerUIView)?.updatePlayer(player: player)
    }
    
    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(player: player)
    }
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    init(player: AVPlayer) {
        super.init(frame: .zero)
        player.play()
        
        playerLayer.player = player
        layer.addSublayer(playerLayer)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    func updatePlayer(player: AVPlayer) {
        self.playerLayer.player = player
    }
}

struct PlayerContainerView : View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var seekPos = 0.0
    
    private let player: AVPlayer
    init(player: AVPlayer) {
        self.player = player
    }
    var body: some View {
        ZStack {
            PlayerView(player: player)
            VStack {
                Spacer()
                PlayerControlsView(player: player)
                
            }
            
        }
    }
}

struct PlayerControlsView : View {
    @Environment(\.presentationMode) var presentationMode
    @State var playerPaused = true
    @State var seekPos = 0.0
    let player: AVPlayer
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)  )
                .fill(Color.gray).opacity(0.2)
                .padding()
                .frame(height: 140)
        
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: playerPaused ? "play.circle" : "pause.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:48, height: 48)
                        .padding(.leading, 70)
                        .padding(.trailing, 20)
                        .foregroundColor(.white)
                        .onTapGesture {
                            self.playerPaused.toggle()
                            if self.playerPaused {
                                self.player.pause()
                            }
                            else {
                                self.player.play()
                            }
                        }
                    
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:24, height: 24)
                        .padding(0)
                        .padding(.trailing, 24)
                        .foregroundColor(.white)
                        .offset(y: -12)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                }
                Slider(value: $seekPos, in: 0...1, onEditingChanged: { _ in
                    guard let item = self.player.currentItem else {
                        return
                    }
                    
                    let targetTime = self.seekPos * item.duration.seconds
                    self.player.seek(to: CMTime(seconds: targetTime, preferredTimescale: 600))
                })
                .padding([.leading, .trailing], 40)
            }
            
        }
    }
}
