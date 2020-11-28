//
//  AvatarViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/27.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import UIKit

class AvatarViewModel: ObservableObject {
    
    @Published var image: UIImage?
    @Published var isShowAlert: Bool = false
    @Published var userInfo: UserInfo
    
    
    fileprivate func getImage(_ avatarUrlString: String?) {
        if let url = avatarUrlString {
        RemoteImageFromUrl.imageDownloaderWithClosure(imageUrl: url, sh: {image in
            DispatchQueue.main.async {
                self.image = image
            }
        })
    }
    }
    
    init(userInfo: UserInfo) {
        
        self.userInfo = userInfo
        
        getImage(userInfo.avatarUrlString)
    }
    
    
    
    /// 拍一拍的实现方法
    /// TODO：自定义动作类型
    /// - Parameter text: 输入的文字
    func tickle(text: String? = "") {
        print(#line, #function, "pat")
        isShowAlert.toggle()
//        let tweetText = "\(fetchMee.info.name ?? "楼主")拍了拍\"\(userName)\" \(text ?? "") \n@\(screenName)"
//        swifter.postTweet(status: tweetText, inReplyToStatusID: self.tweetIDString, autoPopulateReplyMetadata: true, success: {_ in
//            self.alerts.stripAlert.alertText = "Patting sent!"
//            self.alerts.stripAlert.isPresentedAlert = true
//        }, failure: {error in self.isShowAlert = true })
    }
}
