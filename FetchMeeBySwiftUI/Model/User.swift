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
    var isFollowed: Bool?
    var following: Int?
    var followed: Int?
    
    var notifications: Bool?
    
    var tweetsCount: Int?
    var list: [String]?
    
    var setting: UserSetting = UserSetting()
        }

enum ThemeColor: String, CaseIterable, Identifiable {
    case blue
    case green
    case purple
    case pink
    case orange
    case gray
    case auto
    
    var id: String {self.rawValue}
    var color : Color {
        switch self {
        case .blue:     return Color.blue
        case .green:    return Color.green
        case .purple:   return Color.purple
        case .pink:   return Color.pink
        case .orange:   return Color.orange
        case .gray:   return Color.secondary
        case .auto: return withAnimation {colorByDate()}
        }
    }
    
    func randomColor() -> Color {
        let random = Int(arc4random_uniform(6))
        return ThemeColor.allCases[random].color
    }
    
    func colorByDate() -> Color {
        let date = Date()
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "EEEE" //设置格式成获取星期几
        let weekDay = dateFomatter.string(from: date)
        switch weekDay {
        case "Monday": return ThemeColor.blue.color
        case "Tuesday": return ThemeColor.green.color
        case "Wednes": return ThemeColor.purple.color
        case "Thursday": return ThemeColor.pink.color
        case "Friday": return ThemeColor.orange.color
            
        default: return ThemeColor.gray.color
        }
    }
}

struct UserSetting {
    
    var themeColor: ThemeColor = ThemeColor.blue //缺省值是蓝色
    var isIronFansShowed: Bool = true
    /**
     存储用户的设置信息
     */
    func save() {
        userDefault.setValue(self.themeColor.rawValue, forKey: "themeColor")
        userDefault.setValue(self.isIronFansShowed, forKey: "isIronFansShowed")
    }
    /**
     读取用户存储的设置信息
     */
    mutating func load() {
        self.themeColor = ThemeColor(rawValue: (userDefault.object(forKey: "themeColor") as? String) ?? "blue")!
        self.isIronFansShowed = (userDefault.object(forKey: "isIronFansShowed") as? Bool) ?? true
        
    }
}

class User: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var myInfo: UserInfomation = UserInfomation() //当前用户的信息
    @Published var userStore: [String: UserInfomation] = [:] //存储多个用户的信息
    @Published var userStringMark: [String: Int] = [:] // 用户互动数量纪录
    
    @Published var isShowUserInfo: Bool = false
    
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
        self.myInfo.name = json["name"].string!
        self.myInfo.screenName = "@" + json["screen_name"].string!
        self.myInfo.description = json["description"].string!
        
        let ct = json["created_at"].string!.split(separator: " ")
        self.myInfo.createdAt = " Joined " + String(ct[1]) + " " + String(ct[2]) + " " + String(ct[5]) //加入日期
        
        var avatarUrl = json["profile_image_url_https"].string
        avatarUrl = avatarUrl?.replacingOccurrences(of: "_normal", with: "")
        self.avatarDownloader(from: avatarUrl!)()
        
        self.myInfo.bannerUrlString = json["profile_banner_url"].string
        if self.myInfo.bannerUrlString != nil {
        self.myInfo.banner = UIImage(data: (try? Data(contentsOf: URL(string: self.myInfo.bannerUrlString!)!)) ?? UIImage(named: "bg")!.pngData()!)
        }
        
        var loc = json["location"].string ?? "Unknow"
        if loc != "" {
            loc = " " + loc
        }
        self.myInfo.loc = loc
        
        var url = json["url"].string ?? ""
        if url != "" {
            url = " " + url + "\n"
        }
        self.myInfo.url = url
        
        self.myInfo.following = json["friends_count"].integer!
        self.myInfo.followed = json["followers_count"].integer!
        self.myInfo.isFollowing = json["following"].bool
        
        self.myInfo.notifications = json["notifications"].bool
        
        self.myInfo.tweetsCount = json["statuses_count"].integer!
        
    }
    
    func follow() {
        print(#line, #function)
        let userTag = UserTag.id(self.myInfo.id)
        swifter.followUser(userTag)
        self.myInfo.isFollowing = true
    }
    
    func unfollow() {
        let userTag = UserTag.id(self.myInfo.id)
        swifter.unfollowUser(userTag)
        self.myInfo.isFollowing = false
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

extension User {
    /**
     将UserSetting转换成字典文件进行存储
     */
    func saveSetting(setting: UserSetting) -> [String: Int] {
        var settingDic = [String: Int]()
        settingDic["isIronFansShowed"] = setting.isIronFansShowed ? 0 : 1
        return settingDic
    }
}

