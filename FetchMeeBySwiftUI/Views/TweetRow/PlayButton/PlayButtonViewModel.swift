//
//  PlayButtonViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import PhotosUI
import AVKit

class PlayButtonViewModel: ObservableObject {
    var mediaUrlString: String?
    var contextMenuButtons: [ButtonInfo] = []
    
    var player: AVPlayer?
    
    
    init(url: String?) {
        self.mediaUrlString = url
        
        makeContextMenuButton()
    }
    
    func downloadVideo() -> Void {
        videoDownloader(from: mediaUrlString,
                                 sh: {print("Saved")},
                                 fh: {print("UnSaved")})
    }
    
    func makeContextMenuButton() {
        let buttonInfo = ButtonInfo(action: downloadVideo, labelText: "Save Video", labelImage: "folder")
        contextMenuButtons.append(buttonInfo)
    }
    
    func playVideo() {
        if let url = mediaUrlString {
            player = AVPlayer(url: URL(string: url)!)
            }
    }
    
    func stopPlayVideo() {
        player = nil
    }
}

extension PlayButtonViewModel {
    struct ButtonInfo: Identifiable {
        let id = UUID()
        let action: () -> ()
        let labelText: String
        let labelImage: String
    }
}

extension PlayButtonViewModel {
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
