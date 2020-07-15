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

final class Timeline: ObservableObject {
    @Published var tweetIdStrings: [String] = []
    @Published var tweetMedias: [String: TweetMedia] = [:]
    
    
    var type: TweetListType
    
//    let swifter = Swifter(consumerKey: "UUHBnDuEAliSe7vPTC55H12wV",
//                                  consumerSecret: "Rz9FeINJruwxeiOZJGzWOmdFwCQN9NuI8hmRZc1BlW0u0QLqU7",
//                                  oauthToken: "759972733782339584-4ZACqa2TkSuLcTkwsJNcIUpPNzKv6m3",
//                                  oauthTokenSecret: "Pu7lxRcs6dRHlr96tTgdSnU0y9IYvjMFues0QxQsNlxVz")
    
//    let swifter = Swifter(consumerKey: "UdVHYrwJqJN6ZX7K8q7H3A",
//    consumerSecret: "mmM2G8vffvWF9dXHeJvwIy63GeB3Oc7NKxK7MaHvZc",
//    oauthToken: "47585796-oyxjvl2QxPDcjYd09QLihCr4fSsHSXYBjlWDM2usT",
//    oauthTokenSecret: "vNQ6PlsdWFqMVK3OZn6IyoatBLCHB8DdFcHqCzK2zdD6C")
    
    let cfh = CacheFileHandler() //设置下载文件的缓存位置
    let session = URLSession.shared
    
    let maxCounter: Int = 50
    var sinceIDString: String?
    var maxIDString: String?
    
    init(type: TweetListType) {
        self.type = type
    }

    //更新上方推文
    func refreshFromTop() {
        func sh(json: JSON) ->Void {
            let newTweets = json.array ?? []
            self.updateTimelineTop(with: newTweets)
        }
        
        let failureHandler: (Error) -> Void = { error in
            print(#line, error.localizedDescription)}
        
        switch self.type {
        case .mention:
            swifter.getMentionsTimelineTweets(count: 5,sinceID: self.sinceIDString, success: sh, failure: failureHandler)
        case .home:
            swifter.getHomeTimeline(count: self.maxCounter,sinceID: self.sinceIDString,  success: sh, failure: failureHandler)
        default:
            print(#line, #function)
        }
    }
    
    //从推文下方开始更新
    func refreshFromButtom() {
        func sh(json: JSON) ->Void {
            let newTweets = json.array ?? []
            self.updateTimelineBottom(with: newTweets)
        }
        
        let failureHandler: (Error) -> Void = { error in
            print(#line, error.localizedDescription)}
        
        switch self.type {
        case .mention:
            swifter.getMentionsTimelineTweets(count: self.maxCounter, maxID: self.maxIDString, success: sh, failure: failureHandler)
        case .home:
            swifter.getHomeTimeline(count: self.maxCounter,maxID: self.maxIDString,  success: sh, failure: failureHandler)
        default:
            print(#line, #function)
        }
    }
    
    func updateTimelineTop(with newTweets: [JSON]) {
        guard !newTweets.isEmpty else {return}
        let newTweetIDStrings = converJSON2TweetDatas(from: newTweets)
        self.sinceIDString = newTweetIDStrings.first //获取新推文的第一条，作为下次刷新的起始点
        if self.tweetIdStrings.isEmpty {
            self.maxIDString = newTweetIDStrings.last //如果是全新刷新，则需要设置maxIDstring，以保证今后刷新下部推文会从当前最后一条开始。
        }
        
        self.tweetIdStrings = newTweetIDStrings + self.tweetIdStrings
    }
    
    func updateTimelineBottom(with newTweets: [JSON]) {
        guard !newTweets.isEmpty else {return}
        let newTweetIDStrings = converJSON2TweetDatas(from: newTweets)
        self.maxIDString = newTweetIDStrings.last //获取新推文的最后一条，作为下次刷新的起始点
        
        self.tweetIdStrings = self.tweetIdStrings.dropLast() + newTweetIDStrings //需要丢掉原来最后一条推文，否则会重复
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
            
            tweetMedia.userName = newTweets[i]["user"]["name"].string!
            tweetMedia.screenName = newTweets[i]["user"]["screen_name"].string!
            tweetMedia.tweetText = newTweets[i]["text"].string!
            tweetMedia.userIDString = newTweets[i]["user"]["id_str"].string!
            
            tweetMedia.avatarUrlString = newTweets[i]["user"]["profile_image_url_https"].string!
            tweetMedia.avatar = UIImage(systemName: "person.fill")
            avatarDownloader(from: tweetMedia.avatarUrlString!, setTo: IDString)()
//
            if newTweets[i]["extended_entities"]["media"].array?.count != nil {
                let count: Int = newTweets[i]["extended_entities"]["media"].array!.count
                
                tweetMedia.urlStrings = [String]()
                for m in 0..<count {
                    let urlstring = newTweets[i]["extended_entities"]["media"][m]["media_url_https"].string!
                    tweetMedia.urlStrings?.append(urlstring)
                    tweetMedia.images[String(m)] = UIImage(systemName: "person.fill") //先设置占位
                    imageDownloader(from: urlstring, setTo: IDString, at: m)()
                }
            }
            tweetMedia.retweeted = newTweets[i]["retweeted"].bool!
            tweetMedia.favorited = newTweets[i]["favorited"].bool!
            
            tweetMedia.created = newTweets[i]["created_at"].string!
            
            tweetMedia.in_reply_to_user_id_str = newTweets[i]["in_reply_to_user_id_str"].string
            tweetMedia.in_reply_to_status_id_str = newTweets[i]["in_reply_to_status_id_str"].string
            
            
            
            self.tweetMedias[newTweets[i]["id_str"].string!] = tweetMedia
            
        }
        
        return newTweetIDStrings
    }
    
    func avatarDownloader(from urlString: String, setTo idString: String) -> () -> () {
        return{
            
            let url = URL(string: urlString)!
            let fileName = url.lastPathComponent //获取下载文件名用于本地存储
            
            let cachelUrl = self.cfh.getPath()
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
    
    func imageDownloader(from urlString: String, setTo idString: String, at number: Int) -> () -> () {
        return{
            
            let url = URL(string: urlString)!
            let fileName = url.lastPathComponent //获取下载文件名用于本地存储
            
            let cachelUrl = self.cfh.getPath()
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


struct Timeline_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
