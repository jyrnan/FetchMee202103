//
//  Model.swift
//  DataFlow
//
//  Created by jyrnan on 2020/7/10.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import SwiftUI
import  SwifteriOS

struct TweetMedia: Identifiable {
    var id: String
    
    var userName: String?
    var screenName: String?
    var userIDString: String?
    
    var avatarUrlString: String?
    var avatar: Image?
    
    var tweetText: String?
    var created: String?
    
    var urlStrings: [String]?
    var images: [Image]?
    
    var favorited: Bool = false
    var favoriteTimes: Int?
    
    var retweeted: Bool = false
    var retweetedTimes: Int?

    var in_reply_to_user_id_str : String?
    var in_reply_to_status_id_str: String?
    var replyText: String?
    
    init(id: String) {
        self.id = id
    }
}

final class Timeline: ObservableObject {
    @Published var timeline: [String] = []
    @Published var tweetMedias: [String: TweetMedia] = [:]

    private let swifter = Swifter(consumerKey: "UUHBnDuEAliSe7vPTC55H12wV",
                                  consumerSecret: "Rz9FeINJruwxeiOZJGzWOmdFwCQN9NuI8hmRZc1BlW0u0QLqU7",
                                  oauthToken: "759972733782339584-4ZACqa2TkSuLcTkwsJNcIUpPNzKv6m3",
                                  oauthTokenSecret: "Pu7lxRcs6dRHlr96tTgdSnU0y9IYvjMFues0QxQsNlxVz")
    
    func getJSON() {
        func sh(json: JSON) ->Void {
            let newTweets = json.array ?? []
            self.updateTimeline(with: newTweets)
        }
        self.swifter.getHomeTimeline(count: 20,  success: sh, failure: nil)
    }
    
    func updateTimeline(with newTweets: [JSON]) {
        guard !newTweets.isEmpty else {return}
        self.timeline = converJSON2TweetDatas(from: newTweets)
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
            
            
            if newTweets[i]["extended_entities"]["media"].array?.count != nil {
                tweetMedia.urlStrings = [String]()
                
                for m in 0..<newTweets[i]["extended_entities"]["media"].array!.count {
                    tweetMedia.urlStrings?.append(newTweets[i]["extended_entities"]["media"][m]["media_url_https"].string!)
                }
            }
            tweetMedia.retweeted = newTweets[i]["retweeted"].bool!
            tweetMedia.favorited = newTweets[i]["favorited"].bool!
            
            tweetMedia.created = newTweets[i]["created_at"].string!
            
            tweetMedia.in_reply_to_user_id_str = newTweets[i]["in_reply_to_user_id_str"].string
            tweetMedia.in_reply_to_status_id_str = newTweets[i]["in_reply_to_status_id_str"].string
            
            tweetMedia.images = []
            self.tweetMedias[newTweets[i]["id_str"].string!] = tweetMedia
        }
        
        return newTweetIDStrings
    }
}

//enum timelineType: Equatable{
//    case timeline
//}

struct Model_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
