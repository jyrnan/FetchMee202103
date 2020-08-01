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
    var id: String = "0000" //设置成默认ID是“0000”，所以在进行用户信息更新之前需要设置该ID的值
    var name:String?
    var screenName: String?
    var description: String?
    var createdAt: String?
    
    var avatarUrlString: String?
    var avatar: UIImage?
    
    var bannerUrlString: String?
    var banner: UIImage?
    
    var bioText: String?
    var loc: String?
    var url: String?
    
    var isFollowing: Bool?
    var following: Int?
    var followed: Int?
    
    var tweetsCount: Int?
    var list: [String]?
        }

class User: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var myInfo: UserInfomation = UserInfomation() //当前用户的信息
    @Published var userStore: [String: UserInfomation] = [:] //存储多个用户的信息
    @Published var userStringMark: [String: Int] = [:] // 用户互动数量纪录
    let session = URLSession.shared
    
//    init() {
//        if self.isLoggedIn {
//            self.getMyInfo() }
//    }
    
    func getMyInfo() {
        if self.myInfo.id == "0000" && userDefault.object(forKey: "userIDString") != nil { //如果没有设置用户ID，且可以读取userDefualt里的IDString（说明已经logined），则设置loginUser的userIDString为登陆用户的userIDString
            self.myInfo.id = userDefault.object(forKey: "userIDString") as! String
        }
        getUserInfo(for: self.myInfo.id)
    }
    
    func getUserInfo(for userID: String) {
        let userTag = UserTag.id(userID)
        swifter.showUser(userTag, includeEntities: nil, success: getUserBio(json:), failure: nil)
    }
    
    //获取用户信息
    func getUserBio(json: JSON) {
//        let bannerUrl = json["profile_banner_url"].string
        
        var avatarUrl = json["profile_image_url_https"].string
        avatarUrl = avatarUrl?.replacingOccurrences(of: "_normal", with: "")
        
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

