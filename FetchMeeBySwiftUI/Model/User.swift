//
//  User.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/15.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import SwifteriOS
import Combine

struct UserInfomation: Identifiable {
    var id: String = "0000"
    var avatarUrlString: String?
    var avatar: UIImage?
    var bannerUrlString: String?
    var banner: UIImage?
    var bioText: String?
    var following: Bool?
    var list: [String]?
        }

class User: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var myInfo: UserInfomation = UserInfomation()
    
    let session = URLSession.shared
    
    init() {
        self.getMyInfo()
    }
    
    func getMyInfo() {
        self.myInfo.id = userDefault.object(forKey: "userIDString") as! String
        getUserInfo(for: self.myInfo.id)
    }
    
    func getUserInfo(for userID: String) {
        let userTag = UserTag.id(userID)
        swifter.showUser(userTag, includeEntities: nil, success: getUserBio(json:), failure: nil)
    }
    
    func getUserBio(json: JSON) {
        let bannerUrl = json["profile_banner_url"].string
        
        var avatarUrl = json["profile_image_url_https"].string
        avatarUrl = avatarUrl?.replacingOccurrences(of: "_normal", with: "")
        print(#line, avatarUrl)
        self.myInfo.avatar = UIImage(data: try! Data(contentsOf: URL(string: avatarUrl!)!))
        
    }
    
    func avatarDownloader(from urlString: String) -> () -> () {
        return{
            
            let url = URL(string: urlString)!
            let fileName = url.lastPathComponent //获取下载文件名用于本地存储
            
            let cachelUrl = cfh.getPath()
            let filePath = cachelUrl.appendingPathComponent(fileName, isDirectory: false)
            
            
            
            //先尝试获取本地缓存文件
            if let d = try? Data(contentsOf: filePath) {
                if let im = UIImage(data: d) {
                    DispatchQueue.main.async {
                        self.myInfo.avatar = im
//                        print(#line, "从本地获取")
                    }
                }
            } else {
//
                let task = self.session.downloadTask(with: url) {
                    fileURL, resp, err in
                    if let url = fileURL, let d = try? Data(contentsOf: url) {
                        let im = UIImage(data: d)
                        try? d.write(to: filePath)
                        DispatchQueue.main.async {
                            self.myInfo.avatar = im
                        }
                    }
                }
                task.resume()
            }
        }
    }

}
