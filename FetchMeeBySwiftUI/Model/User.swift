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


struct User: Identifiable, Codable {
    var id: String = "0000" //设置成默认ID是“0000”，所以在进行用户信息更新之前需要设置该ID的值
    var name:String = "Name"
    var screenName: String = "ScreenName"
    var nickName: String?
    var description: String = ""
    var createdAt: Date = Date()
    
    var tokenKey: String?
    var tokenSecret: String?
    
    var avatarUrlString: String = ""
    var bannerUrlString: String = ""
    
    var bioText: String = ""
    var loc: String?
    var url: String?
    
    var isFollowing: Bool = false
    var isFollowed: Bool = false
    var following: Int = 0
    var followed: Int = 0
    
    var notifications: Bool = false
    
    var tweets: Int = 0
       
    var followersAddedOnLastDay: Int = 0 //24小时内新增fo数
    var tweetsPostedOnLastDay: Int = 0 //24小时内新增推数
    
    var isLoginUser = false
    var isLocalUser = false
    var isFavoriteUser = false
    var isBookmarkedUser = false
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

enum UIStyle: String, CaseIterable, Identifiable, Codable {
   
    case card
    case plain
    
    var id:String {self.rawValue}
    var radius: CGFloat {
        switch self {
        case .card: return 16
        case .plain: return 0
        }
    }
    var insetH: CGFloat {
        switch self {
        case .card: return 16
        case .plain: return 0
        }
    }
    var insetV: CGFloat {
        switch self {
        case .card: return 4
        case .plain: return 0
        }
    }
    var backGround: Color {
        switch self {
        case .card: return Color.init("BackGroundLight")
        case .plain: return Color.init("BackGround")
        }
    }
    var avatarWidth: CGFloat { 36 }
    
}


struct UserSetting: Codable {
    
    var themeColor: ThemeColor = ThemeColor.blue //缺省值是蓝色
    var uiStyle: UIStyle = .card //卡片式样
    var isIronFansShowed: Bool = false
    var isMediaShowed: Bool = true //控制是否显示图片、视频
    var isAutoFetchMoreTweet: Bool = true //控制是否自动载入更多推文
    var isDeleteTweets: Bool = false //控制是否删推
    var isKeepRecentTweets: Bool = true //控制是否保留最近推文
    
    var isFirsResponder: Bool = false //控制是否激活推文输入框，还没完全搞定，暂未使用
   
}

extension User {
    struct MentionUser: Codable, Equatable {
       
        let id: String
        let avatarUrlString: String
        var mentionsIDs: Set<String> = []
        var count:Int {return self.mentionsIDs.count}
    }
}
