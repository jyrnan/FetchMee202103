//
//  User.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/15.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine
import CoreData

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
    var lists: [String : ListTag] = [:]
    
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
        case .blue:     return Color.init("TwitterBlue")
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
        case "Wednesday": return ThemeColor.purple.color
        case "Thursday": return ThemeColor.pink.color
        case "Friday": return ThemeColor.orange.color
            
        default: return ThemeColor.gray.color
        }
    }
}

struct UserSetting {
    
    var themeColor: ThemeColor = ThemeColor.blue //缺省值是蓝色
    var isIronFansShowed: Bool = false
    var isMediaShowed: Bool = true //控制是否显示图片、视频
    var isDeleteTweets: Bool = false //控制是否删推
    var isKeepRecentTweets: Bool = true //控制是否保留最近推文
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

class User: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var myInfo: UserInfomation = UserInfomation() //当前用户的信息
    @Published var userStore: [String: UserInfomation] = [:] //存储多个用户的信息
    @Published var userStringMark: [String: Int] = [:] // 用户互动数量纪录
    @Published var isShowUserInfo: Bool = false
    
    @Published var home: Timeline = Timeline(type: .home)
    @Published var mention: Timeline = Timeline(type: .mention)
    @Published var message: Timeline = Timeline(type: .message)
    
    var myUserline: Timeline = Timeline(type: .user) //创建一个自己推文的timeline
    
    let session = URLSession.shared
    
    //CoreData part
    let context = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.delegate as? SceneDelegate)?.context
    
    
    //MARK:-获取用户信息方法
    func getMyInfo() {
        
        var userTag: UserTag?
        if let screenName = self.myInfo.screenName {
            userTag = UserTag.screenName(String(screenName.dropFirst())) //去掉前面的@符号
        } else {
            //如果没有设置用户ID，且可以读取userDefualt里的IDString（说明已经logined），则设置loginUser的userIDString为登陆用户的userIDString
            if self.myInfo.id == "0000" && userDefault.object(forKey: "userIDString") != nil {
                self.myInfo.id = userDefault.object(forKey: "userIDString") as! String
            }
            userTag = UserTag.id(self.myInfo.id)
        }
        
        //读取用户设置信息
        myInfo.setting.load()
        
        guard userTag != nil else {return}
        getUserInfo(for: userTag!)
    }
    
    func getUserInfo(for userTag: UserTag) {
        print(#line, #function)
        print(userTag)
        swifter.showUser(userTag, includeEntities: nil, success: getUserBio(json:), failure: nil)
        swifter.getSubscribedLists(for: userTag, success: updateList, failure: nil)
    }
    
    
    /// 获取用户List信息并更新
    /// - Parameter json: 返回的包含list信息的结果
    func updateList(json: JSON) {
        
        let lists: [JSON] = json.array!
        
        var newLists: [String : ListTag] = [:]
        for list in lists {
            let name: String = list["name"].string!
            let idString: String = list["id_str"].string!
            let listTag = ListTag.id(idString)
            newLists[name] = listTag
        }
        
        if newLists.isEmpty {
            let name: String = "No List"
            let idString: String = "0000"
            let listTag = ListTag.id(idString)
            newLists[name] = listTag
        }
        
        self.myInfo.lists = newLists
        
        
    }
    
    //获取用户信息
    func getUserBio(json: JSON) {
        print(#line, #function)
        self.myInfo.id = json["id_str"].string!
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
        
        //保存用户信息到CoreData，如果是登陆用户，则传入true
        saveUserInfoToCoreData(id: self.myInfo.id, isLoginUser: self.isLoggedIn)
        
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
    
    func saveUserInfoToCoreData(id: String, isLoginUser: Bool = false) {
        
        var currentUser: TwitterUser?
        
        guard let windowsScenen = UIApplication.shared.connectedScenes.first as? UIWindowScene ,
              let sceneDelegate = windowsScenen.delegate as? SceneDelegate
        else {
            return
        }
        let viewContext = sceneDelegate.context
        
        let userFetch: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        userFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(TwitterUser.userIDString), id)
        
        do {
            let results = try viewContext.fetch(userFetch)
            
            if results .count > 0 {
                currentUser = results.first
            } else {
                currentUser = TwitterUser(context: viewContext)
            }
            
            
            currentUser?.userIDString = id
            currentUser?.name = myInfo.name
            currentUser?.screenName = myInfo.screenName
            currentUser?.avatar = myInfo.avatarUrlString
            
            currentUser?.following = Int32(myInfo.following ?? 0)
            currentUser?.followed = Int32(myInfo.followed ?? 0)
            currentUser?.isFollowing = myInfo.isFollowing ?? true
            
            //如果是当前用户，则统计推文数量等动态信息
            if isLoginUser {
            let count: Count = Count(context: viewContext)
            count.createdAt = Date()
            count.follower = Int32(myInfo.followed ?? 0)
            count.following = Int32(myInfo.following ?? 0)
            count.tweets = Int32(myInfo.tweetsCount ?? 0)
            
            currentUser?.addToCount(count)
            }
            
            try viewContext.save()
            
        }catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
    }
}
