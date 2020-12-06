//
//  UserViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/6.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import UIKit
import Swifter

class UserViewModel: ObservableObject {
    var userIDString: String
    @Published var user: JSON!

    
    @Published var avataImage: UIImage!
    @Published var bannerImage: UIImage!
    
    
    init(userIDString: String) {
        self.userIDString = userIDString
        print(#line, #function, #file)
        
        //获取用户的JSON信息，获取信息后执行回调函数获取图片
        getUser(userIDString: userIDString, completeHandeler: downloadMedias)
    }
    
    
    /// 获取用户的JSON信息
    /// - Parameters:
    ///   - userIDString: 用户ID
    ///   - completeHandeler: 获取用户信息后执行的操作
    /// - Returns: nil
    func getUser(userIDString: String, completeHandeler: @escaping ()->()) {
        ///如果用户仓库无法获取，则直接从网上获取，并存入信息至仓库
        if let user = UserRepository.shared.users[userIDString] {
            self.user = user
            completeHandeler()
        } else {
            let sh:(JSON) -> () = {json in
                self.user = json
                UserRepository.shared.addUser(json)
                completeHandeler()
            }
            swifter.showUser(UserTag.id(userIDString), success: sh)
        }
    }
    
   
    func downloadMedias() {
        getavatarImage()
        getBannerImage()
    }
    
    fileprivate func getavatarImage() {
        if var url = user["profile_image_url_https"].string {
            url = url.replacingOccurrences(of: "_normal", with: "")
        RemoteImageFromUrl.imageDownloaderWithClosure(imageUrl: url, sh: {image in
            DispatchQueue.main.async {
                self.avataImage = image
            }
        })
    }
    }
    
    fileprivate func getBannerImage() {
        if var url = user["profile_banner_url"].string {
            
        RemoteImageFromUrl.imageDownloaderWithClosure(imageUrl: url, sh: {image in
            DispatchQueue.main.async {
                self.bannerImage = image
            }
        })
    }
    }
    
//    func makeUserTimelineView() -> Timelineview {
//        return TimelineView()
//    }
}
