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
        self.myInfo.avatar = UIImage(data: try! Data(contentsOf: URL(string: avatarUrl!)!))
        
    }
    

}

