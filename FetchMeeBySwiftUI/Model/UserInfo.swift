//
//  User.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine
import CoreData


struct UserInfo: Identifiable, Codable {
    var id: String = "0000" //设置成默认ID是“0000”，所以在进行用户信息更新之前需要设置该ID的值
    var name:String?
    var screenName: String?
    var nickName: String?
    var description: String?
    var createdAt: String?
    
    var tokenKey: String?
    var tokenSecret: String?
    
    var avatarUrlString: String?
//    var avatar: UIImage?
    
    var bannerUrlString: String?
//    var banner: UIImage?
    
    var bioText: String?
    var loc: String?
    var url: String?
    
    var isFollowing: Bool?
    var isFollowed: Bool?
    var following: Int?
    var followed: Int?
    
    var notifications: Bool?
    
    var tweetsCount: Int?
   
    var setting: UserSetting = UserSetting()
    
    var lastDayAddedFollower: Int? //24小时内新增fo数
    var lastDayAddedTweets: Int? //24小时内新增推数
}

enum ThemeColor: String, CaseIterable, Identifiable, Codable {
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
        case .blue:     return Color.init("TwitterBlue")
        case .green:    return Color.init("DarkGreen")
        case .purple:   return Color.purple
        case .pink:   return Color.pink
        case .orange:   return Color.init("DarkOrange")
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
        case "Wednesday": return ThemeColor.purple.color
        case "Thursday": return ThemeColor.pink.color
        case "Friday": return ThemeColor.orange.color
            
        default: return ThemeColor.gray.color
        }
    }
}

struct UserSetting: Codable {
    
    var themeColor: ThemeColor = ThemeColor.blue //缺省值是蓝色
    var isIronFansShowed: Bool = false
    var isMediaShowed: Bool = true //控制是否显示图片、视频
    var isDeleteTweets: Bool = false //控制是否删推
    var isKeepRecentTweets: Bool = true //控制是否保留最近推文
    
    var isFirsResponder: Bool = false //控制是否激活推文输入框，还没完全搞定，暂未使用
    /**
     存储用户的设置信息
     */
    func save() {
        userDefault.setValue(self.themeColor.rawValue, forKey: "themeColor")
        userDefault.setValue(self.isIronFansShowed, forKey: "isIronFansShowed")
        userDefault.setValue(self.isMediaShowed, forKey: "isMediaShowed")
        userDefault.setValue(self.isDeleteTweets, forKey: "isDeleteTweets")
        userDefault.setValue(self.isKeepRecentTweets, forKey: "isKeepRecentTweets")
        print(#line, "Settings saved!")
    }
    /**
     读取用户存储的设置信息
     */
    mutating func load() {
        self.themeColor = ThemeColor(rawValue: (userDefault.object(forKey: "themeColor") as? String) ?? "blue")!
        self.isIronFansShowed = (userDefault.object(forKey: "isIronFansShowed") as? Bool) ?? true
        self.isMediaShowed = (userDefault.object(forKey: "isMediaShowed") as? Bool) ?? true
        self.isDeleteTweets = (userDefault.object(forKey: "isDeleteTweets") as? Bool) ?? false
        self.isKeepRecentTweets = (userDefault.object(forKey: "isKeepRecentTweets") as? Bool) ?? false
    }
}
