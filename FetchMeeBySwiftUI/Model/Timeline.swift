//
//  Timeline.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import SwiftUI
import SwifteriOS
import Combine

enum TweetListType: String {
    case home = "Home"
    case mention = "Mentions"
    case list
    case user
    case session
}

final class Timeline: ObservableObject {
    @Published var tweetIDStrings: [String] = []
    @Published var tweetMedias: [String: TweetMedia] = [:]
    @Published var newTweetNumber: Int = 0
    @Published var isDone: Bool = true { //设定在更新任务时候状态指示器是否显示，但无论任务是否结束，10秒种后状态指示器消失
        
        didSet {
            delay(delay: 10, closure: {
                if self.isDone  == false {
                    self.isDone = true
                }
            })
        }
    }
//    @Published var mentionUserSortedList: [UserInfomation] = []
    
    @Published var mentionUserIDStringsSorted: [String] = [] //存储根据MentiUserinfo情况排序的UserIDString
    @Published var userInfos: [String : UserInfomation] = [:] //存储UserInfo供调用
    
    var type: TweetListType
    var tweetIDStringOfRowToolsViewShowed: String? //显示ToolsView的推文ID
    var mentionUserInfo: [String:[String]] = [:] {
        didSet {
//            print(#line, self.mentionUserInfo.count)
            
            userDefault.set(self.mentionUserInfo, forKey: "mentionUserInfo")
//            print(#line, "\(self.type) mentionUserInfo saved!")
        }
    } //记录用户互动mention推文信息（推文ID）数量,纪录顺序[userName, screenName, avatarUrlString, tweetID...tweetID]
    
    
//    let swifter = Swifter(consumerKey: "UUHBnDuEAliSe7vPTC55H12wV",
//                                  consumerSecret: "Rz9FeINJruwxeiOZJGzWOmdFwCQN9NuI8hmRZc1BlW0u0QLqU7",
//                                  oauthToken: "759972733782339584-4ZACqa2TkSuLcTkwsJNcIUpPNzKv6m3",
//                                  oauthTokenSecret: "Pu7lxRcs6dRHlr96tTgdSnU0y9IYvjMFues0QxQsNlxVz")
    
//    let swifter = Swifter(consumerKey: "UdVHYrwJqJN6ZX7K8q7H3A",
//    consumerSecret: "mmM2G8vffvWF9dXHeJvwIy63GeB3Oc7NKxK7MaHvZc",
//    oauthToken: "47585796-oyxjvl2QxPDcjYd09QLihCr4fSsHSXYBjlWDM2usT",
//    oauthTokenSecret: "vNQ6PlsdWFqMVK3OZn6IyoatBLCHB8DdFcHqCzK2zdD6C")
    
    let session = URLSession.shared
    let maxCounter: Int = 50
    var sinceIDString: String?
    var maxIDString: String?
    
    init(type: TweetListType) {
        self.type = type
        print(#line, "timeline(\(self.type)) init", self)
        switch type {
        case .session:
            print()
        case .mention:
            self.mentionUserInfo = userDefault.object(forKey: "mentionUserInfo") as? [String:[String]] ?? [:] //读取数据
//            print(#line, self.mentionUserInfo)
            self.makeMentionUserSortedList()//初始化更新MentionUser排序
            self.refreshFromTop()

        default:
            self.refreshFromTop()
            print()
        }
        
        
    }
    
    deinit {
        
        switch type {
        case .mention:
            print(#line, self.mentionUserInfo.count)
//            userDefault.set(self.mentionUserInfo, forKey: "mentionUserInfo") //存储
//            print(#line, "\(self.type) mentionUserInfo saved!")
        default:
            print(#line, "\(self.type) disappeared!")
        }
    }

    //更新上方推文
    func refreshFromTop(for userIDString: String? = nil) {
        func sh(json: JSON) ->Void {
            let newTweets = json.array ?? []
            print(#line, "Timeline got!", self, Date())
            
                self.newTweetNumber = newTweets.count
            
            self.isDone = true
            self.makeMentionUserSortedList() //存储MentionUserInfo并更新MentionUser的排序
            self.updateTimelineTop(with: newTweets)
        }
        
        let failureHandler: (Error) -> Void = { error in
            print(#line, error.localizedDescription)}
        
        switch self.type {
        case .mention:
            swifter.getMentionsTimelineTweets(count: 5,sinceID: self.sinceIDString, success: sh, failure: failureHandler)
        case .home:
            swifter.getHomeTimeline(count: self.maxCounter,sinceID: self.sinceIDString,  success: sh, failure: failureHandler)
        case .user:
            swifter.getTimeline(for: UserTag.id(userIDString ?? "0000"), success: sh, failure: failureHandler)
        default:
            print(#line, #function)
        }
    }
    
    //从推文下方开始更新
    func refreshFromButtom() {
        func sh(json: JSON) ->Void {
            let newTweets = json.array ?? []
            self.isDone = true
            self.updateTimelineBottom(with: newTweets)
            self.isDone = true
            self.makeMentionUserSortedList() //存储MentionUserInfo并更新MentionUser的排序
        }
        
        let failureHandler: (Error) -> Void = { error in
            print(#line, error.localizedDescription)}
        
        switch self.type {
        case .mention:
            self.isDone = false
            swifter.getMentionsTimelineTweets(count: self.maxCounter, maxID: self.maxIDString, success: sh, failure: failureHandler)
        case .home:
            self.isDone = false
            swifter.getHomeTimeline(count: self.maxCounter,maxID: self.maxIDString,  success: sh, failure: failureHandler)
       
        default:
            print(#line, #function)
        }
    }
    
    func updateTimelineTop(with newTweets: [JSON]) {
        guard !newTweets.isEmpty else {return}
        let newTweetIDStrings = converJSON2TweetDatas(from: newTweets)
        self.sinceIDString = newTweetIDStrings.first //获取新推文的第一条，作为下次刷新的起始点
        if self.tweetIDStrings.isEmpty {
            self.maxIDString = newTweetIDStrings.last //如果是全新刷新，则需要设置maxIDstring，以保证今后刷新下部推文会从当前最后一条开始。
        }
        
        self.tweetIDStrings = newTweetIDStrings + self.tweetIDStrings
    }
    
    func updateTimelineBottom(with newTweets: [JSON]) {
        guard !newTweets.isEmpty else {return}
        let newTweetIDStrings = converJSON2TweetDatas(from: newTweets)
        self.maxIDString = newTweetIDStrings.last //获取新推文的最后一条，作为下次刷新的起始点
        
        self.tweetIDStrings = self.tweetIDStrings.dropLast() + newTweetIDStrings //需要丢掉原来最后一条推文，否则会重复
    }
    
   func  converJSON2TweetDatas(from newTweets: [JSON]) -> [String] {
        //转换JSON格式推文数据成本地数据模型，并生成相应推文的Media数据结构
        let newTweets = newTweets
        var newTweetIDStrings = [String]()
        for i in newTweets.indices {
            //将获取的推文数据转换成本地数据格式
            let IDString = newTweets[i]["id_str"].string!
            newTweetIDStrings.append(IDString)
            
            //生产对应推文的媒体数据字典，根据推文IDString进行索引
            var tweetMedia = TweetMedia(id: newTweets[i]["id_str"].string!)
            
            tweetMedia.userIDString = newTweets[i]["user"]["id_str"].string!
            tweetMedia.userName = newTweets[i]["user"]["name"].string!
            tweetMedia.screenName = newTweets[i]["user"]["screen_name"].string!
            
            tweetMedia.replyUsers = self.convertTweetText(from: newTweets[i]["text"].string!).0
            tweetMedia.tweetText = self.convertTweetText(from: newTweets[i]["text"].string!).1
            
            tweetMedia.avatarUrlString = newTweets[i]["user"]["profile_image_url_https"].string!
            tweetMedia.avatarUrlString = tweetMedia.avatarUrlString?.replacingOccurrences(of: "_normal", with: "")
            tweetMedia.avatar = UIImage(systemName: "person.fill")
            avatarDownloader(from: tweetMedia.avatarUrlString!, setTo: IDString)()
//
            if newTweets[i]["extended_entities"]["media"].array?.count != nil {
                let count: Int = newTweets[i]["extended_entities"]["media"].array!.count
                
                tweetMedia.urlStrings = [String]()
                for m in 0..<count {
                    let urlstring = newTweets[i]["extended_entities"]["media"][m]["media_url_https"].string!
                    tweetMedia.urlStrings?.append(urlstring)
                    tweetMedia.images[String(m)] = UIImage(named: "defaultImage") //先设置占位
                    imageDownloader(from: urlstring, setTo: IDString, at: m)()
                }
            }
            tweetMedia.retweeted = newTweets[i]["retweeted"].bool!
            tweetMedia.favorited = newTweets[i]["favorited"].bool!
            
            tweetMedia.created = newTweets[i]["created_at"].string!
            
            tweetMedia.in_reply_to_user_id_str = newTweets[i]["in_reply_to_user_id_str"].string
            tweetMedia.in_reply_to_status_id_str = newTweets[i]["in_reply_to_status_id_str"].string
            
            if self.type == .mention {
                let userIDString = newTweets[i]["user"]["id_str"].string!
                let userName = newTweets[i]["user"]["name"].string!
                let screenName = newTweets[i]["user"]["screen_name"].string!
                let avatarUrlString = newTweets[i]["user"]["profile_image_url_https"].string!.replacingOccurrences(of: "_normal", with: "")
                let tweetID = newTweets[i]["in_reply_to_status_id_str"].string ?? "0000"
                
                if self.mentionUserInfo[userIDString] == nil {
                    self.mentionUserInfo[userIDString] = [userName, screenName, avatarUrlString, tweetID]
                } else {
                    if self.mentionUserInfo[userIDString]?.contains(tweetID) == false {
                        self.mentionUserInfo[userIDString]?.append(tweetID)
                    }
                }
                //
                if self.userInfos[userIDString] == nil {
                    var userInfo = UserInfomation(id: userIDString)
                    userInfo.name = userName
                    userInfo.screenName = screenName
                    userInfo.avatarUrlString = avatarUrlString
                    userInfo.avatar = UIImage(systemName: "person.fill")
                    avatarForUserDownloader(from: userInfo.avatarUrlString!, setTo: userIDString)()
                    self.userInfos[userIDString] = userInfo
                }
                
                
//                print(#line,self.mentionUserInfo)
            }
            
            self.tweetMedias[newTweets[i]["id_str"].string!] = tweetMedia
            
        }
        
        return newTweetIDStrings
    }
    
    func convertTweetText(from originalTweetText: String) -> ([String], [String]) {
        var replyUsers: [String] = []
        var tweetText: [String] = []
        
        tweetText = originalTweetText.split(separator: " ").map{String($0)}
        
        for string in tweetText {
            if string.first != "@" {
                break
            }
            replyUsers.append(string)
        }
        if !replyUsers.isEmpty {
            tweetText.removeFirst(replyUsers.count)
        }
        return (replyUsers, tweetText)
    }
    
    func avatarDownloader(from urlString: String, setTo idString: String) -> () -> () {
        return{
            
            let url = URL(string: urlString)!
            let fileName = url.lastPathComponent //获取下载文件名用于本地存储
            
            let cachelUrl = cfh.getPath()
            let filePath = cachelUrl.appendingPathComponent(fileName, isDirectory: false)
            
            
            
            //先尝试获取本地缓存文件
            if let d = try? Data(contentsOf: filePath) {
                if let im = UIImage(data: d) {
                    DispatchQueue.main.async {
                        self.tweetMedias[idString]?.avatar = im
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
                            self.tweetMedias[idString]?.avatar = im
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    func avatarForUserDownloader(from urlString: String, setTo idString: String) -> () -> () {
        return{
            
            let url = URL(string: urlString)!
            let fileName = url.lastPathComponent //获取下载文件名用于本地存储
            
            let cachelUrl = cfh.getPath()
            let filePath = cachelUrl.appendingPathComponent(fileName, isDirectory: false)
            
            
            
            //先尝试获取本地缓存文件
            if let d = try? Data(contentsOf: filePath) {
                if let im = UIImage(data: d) {
                    DispatchQueue.main.async {
                        self.userInfos[idString]?.avatar = im
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
                            self.userInfos[idString]?.avatar = im
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    func imageDownloader(from urlString: String, setTo idString: String, at number: Int) -> () -> () {
        return{
            
            let url = URL(string: urlString)!
            let fileName = url.lastPathComponent //获取下载文件名用于本地存储
            
            let cachelUrl = cfh.getPath()
            let filePath = cachelUrl.appendingPathComponent(fileName, isDirectory: false)
            
            
            
            //先尝试获取本地缓存文件
            if let d = try? Data(contentsOf: filePath) {
                if let im = UIImage(data: d) {
                    DispatchQueue.main.async {
                        self.tweetMedias[idString]?.images[String(number)] = im
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
                            self.tweetMedias[idString]?.images[String(number)] = im
                        }
                    }
                }
                task.resume()
            }
        }
    }
}

extension Timeline {
    func getReplyDetail(for idString: String) {
        self.isDone = false
        let failureHandler: (Error) -> Void = { error in
            print(#line, error.localizedDescription)}
        
        var counter: Int = 0
        
        func finalReloadView() {
            //最后操作，可能需要
            self.isDone = true
//            self.tweetMedias[idString]?.isToolsViewShowed = true
        
            
        }
        func sh(json: JSON) -> () {
                        print(#line, "第\(counter)次成功")
//                        print(#line, json)
                        print(#line, self.tweetIDStrings)
            let newTweets = [json]
//                        print(#line, newTweets)
            let newTweetIDStrings = converJSON2TweetDatas(from: newTweets)
                        print(#line, newTweetIDStrings)
            self.tweetIDStrings = newTweetIDStrings + self.tweetIDStrings
            if let in_reply_to_status_id_str = json["in_reply_to_status_id_str"].string, counter < 8 {
                swifter.getTweet(for: in_reply_to_status_id_str, success: sh, failure: failureHandler)
                counter += 1
            } else {
                //                print(#line, "执行tableview重载")
                finalReloadView()
            }
        }
        swifter.getTweet(for: idString, success: sh, failure: failureHandler)
    }
}

extension Timeline {
    func makeMentionUserSortedList() {
        
        guard self.type == .mention else {return}
        print(#line, "MakementionUserSotedList")
        userDefault.set(self.mentionUserInfo, forKey: "mentionUserInfo")
        
        let mentionUserInfoSorted = self.mentionUserInfo.sorted{$0.value.count > $1.value.count} //按Mention数量照降序排序
        
        self.mentionUserIDStringsSorted = []
        
        for user in mentionUserInfoSorted {
            let userIDString = user.key
            let userName = user.value[0] //第一个值是Name,下面类推
            let screenName = user.value[1]
            let avatarUrlString = user.value[2]
            
            self.mentionUserIDStringsSorted.append(userIDString)
            
            if self.userInfos[userIDString] == nil {
                var userInfo = UserInfomation(id: userIDString)
                    userInfo.name = userName
                    userInfo.screenName = screenName
                    userInfo.avatarUrlString = avatarUrlString
                    userInfo.avatar = UIImage(systemName: "person.fill")
                self.avatarForUserDownloader(from: userInfo.avatarUrlString!, setTo: userIDString)()
                    self.userInfos[userIDString] = userInfo
            }
            
        }
        for user in self.mentionUserIDStringsSorted {
//            print(#line, user, self.userInfos[user]?.name)
        }
    }
    
}

extension Timeline {
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

struct Timeline_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
