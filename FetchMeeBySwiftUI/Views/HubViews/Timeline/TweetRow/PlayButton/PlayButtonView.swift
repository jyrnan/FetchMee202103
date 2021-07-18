//
//  PlayButtonView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import AVKit
import PhotosUI

struct PlayButtonView: View {
    var mediaUrlString: String
    var contextMenuButtons: [ButtonInfo] = []
    init(url: String) {
        self.mediaUrlString = url
        let button = ButtonInfo(action: downloadVideo, labelText: "Save Video", labelImage: "folder")
        contextMenuButtons.append(button)
    }
    @State var playVideo: Bool = false
    
    var body: some View {
        Image(systemName: "play.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 48, height: 48, alignment: .center)
            .foregroundColor(.gray)
            .background(Circle().foregroundColor(.white))
            .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                ForEach(contextMenuButtons) {
                    button in
                    Button(action: button.action, label: {
                        Text(button.labelText)
                        Image(systemName: button.labelImage)
                    })
                }
               
            }/*@END_MENU_TOKEN@*/)
            .onTapGesture(count: 1, perform: {
                        self.playVideo = true
            })
            .fullScreenCover(isPresented: self.$playVideo,  content: {
                VideoPlayView(url: mediaUrlString) //用官方的播放器了
            })
    }
}

struct PlayButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PlayButtonView(url: "")
            .preferredColorScheme(.dark)
    }
}

extension PlayButtonView {
    struct ButtonInfo: Identifiable {
        let id = UUID()
        let action: () -> ()
        let labelText: String
        let labelImage: String
    }
    
    func downloadVideo() -> Void {
        videoDownloader(from: mediaUrlString,
                                 sh: {print("Saved")},
                                 fh: {print("UnSaved")})
    }
    
    /// 一个用来下载视频的代码，下载后会把视频文件保存的手机的相册，期间会在app的暂存位置保存，名字为timpFile.mp4
    /// - Parameters:
    ///   - urlString: 视频的url地址
    ///   - sh: 视频存储成功后执行的闭包
    ///   - fh: 视频存储失败时执行的闭包
    /// - Returns: 没有返回值。其结果的处理应该在sh或者fh里面实现
    func videoDownloader(from urlString: String?, sh:@escaping ()->Void, fh:@escaping ()->Void ) -> Void {
        if let urlString = urlString {

        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: urlString),
                let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/tempFile.mp4"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }){ completed, error in
                        if completed {
                           
                            DispatchQueue.main.async{sh()}
                        }
                        if error != nil {
                            fh()
                        }
                    }
                }
            }
        }
    }
    }
}
