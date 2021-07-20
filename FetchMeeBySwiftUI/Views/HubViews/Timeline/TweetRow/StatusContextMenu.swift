//
//  StatusContextMenu.swift
//  StatusContextMenu
//
//  Created by jyrnan on 2021/7/18.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import AVKit
import PhotosUI

struct StatusContextMenu: View {
    @ObservedObject var store: Store
    var status: Status
    var contextMenuButtons: [ButtonInfo] = []
    
    init(store: Store, status: Status) {
        self.store = store
        self.status = status
        setupContextMenuButtons(status: status)
    }
    
    var body: some View {
        ForEach(contextMenuButtons) {
            button in
            Button(role: button.role, action: button.action, label: {
                Text(button.labelText)
                Image(systemName: button.labelImage)
            })
        }
    }
    
    private mutating func setupContextMenuButtons(status: Status) {
        
        let favoriteButton = ButtonInfo(role: nil,
                                action: favoriteTweet,
                                labelText: status.favorited ? "Unfavorite" : "Favorite",
                                labelImage: status.favorited ? "heart.slash" : "heart")
        contextMenuButtons.append(favoriteButton)
        
        let button = ButtonInfo(role: nil,
                                action: retweetTweet,
                                labelText: status.retweeted ? "UnRetweet" : "Retweet",
                                labelImage: "arrow.2.squarepath")
        contextMenuButtons.append(button)
        
        if status.mediaUrlString != nil  {
            let button = ButtonInfo(role: nil, action: downloadVideo, labelText: "Save Video", labelImage: "folder")
            contextMenuButtons.append(button)
        }
    }
    
    func favoriteTweet() {
        store.dispatch(.tweetOperation(operation: status.favorited ? .unfavorite(id: status.id) : .favorite(id: status.id)))
    }
    
    func retweetTweet() {
        store.dispatch(.tweetOperation(operation: status.retweeted ? .unRetweet(id: status.id) : .retweet(id: status.id)))
    }
}

extension StatusContextMenu {
    struct ButtonInfo: Identifiable {
        let id = UUID()
        let role: ButtonRole?
        let action: () -> ()
        let labelText: String
        let labelImage: String
    }
    
    
    
    func downloadVideo() -> Void {
        videoDownloader(from: status.mediaUrlString,
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


struct ContextMenuView_Previews: PreviewProvider {
    static var previews: some View {
        StatusContextMenu(store: Store.sample, status: Status.sample)
    }
}
