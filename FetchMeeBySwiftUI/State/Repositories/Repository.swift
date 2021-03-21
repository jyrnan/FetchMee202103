//
//  Repository.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/17.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Swifter

class Repository  {
    
//    static var shared = Repository()
//    private init() {}
    
    weak var store: Store?
    
    var status: [String: Status] = [:]
    var users: [String: UserInfo] = [:]
    
    func addStatus(data: JSON) {
        if let id = data["id_str"].string {
            status[id] = convertToStatus(from: data)
        }
    }
    
    func addUser(data: JSON) {
        if let id = data["id_str"].string {
            users[id] = convertToUser(from: data)
        }
    }
}

extension Repository {
    func convertToUser(from json: JSON) -> UserInfo {
        var user = UserInfo()
        user.id = json["id_str"].string!
        user.name = json["name"].string
        user.screenName = json["screen_name"].string
        user.description = json["description"].string
        user.createdAt = json["created_at"].string
         
        user.avatarUrlString = json["profile_image_url_https"].string
        user.bannerUrlString = json["profile_banner_url"].string
        
        user.loc = json["location"].string
        user.url = json["url"].string
        
        user.isFollowing = json["following"].bool
        user.isFollowed = json["follow_request_sent"].bool
        user.following = json["friends_count"].integer
        user.followed = json["followers_count"].integer
        
        user.notifications = json["screen_name"].bool
        
        user.tweetsCount = json["statuses_count"].integer
        
        return user
    }
    
    func convertToStatus(from json: JSON) -> Status {
        var status = Status(id: json["id_str"].string!)
        status.user = convertToUser(from: json["user"])
        
        status.text = json["text"].string
        status.attributedText = json.getAttributedText()
        status.createdAt = convertToDate(from: json["created_at"].string)
        
        status.imageUrls = getImageUrls(from: json) //图片的url
        
        status.mediaType = json["extended_entities"]["media"].array?.first?["type"].string
        status.mediaUrlString = json["extended_entities"]["media"].array?.first?["video_info"]["variants"].array?.first?["url"].string
        
        status.favorited = json["favorited"].bool!
        status.favorite_count = json["favorite_count"].integer
        
        status.retweeted = json["retweeted"].bool!
        status.retweet_count = json["retweet_count"].integer
        
        status.retweeted_status_id_str = json["retweeted_status"]["id_str"].string
        status.quoted_status_id_str = json["quoted_status_id_str"].string //引用推文的ID

        status.in_reply_to_user_id_str = json["in_reply_to_user_id_str"].string
        status.in_reply_to_status_id_str = json["in_reply_to_status_id_str"].string
        
        status.source = json["source"].string
        
        status.isMentioned = checkIsMentioned(from: json)
        
        return status
  }
    
    func convertToDate(from created_at: String?) -> Date? {
        guard let timeString = created_at else {
            return nil
        }
            let timeFormat = DateFormatter()
            timeFormat.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            return timeFormat.date(from: timeString)
    }
    
    func getImageUrls(from json: JSON) -> [String]? {
        guard let medias = json["extended_entities"]["media"].array  else {  return nil }
        
        return medias.map{$0["media_url_https"].string!
    }
    }
    
    func checkIsMentioned(from json: JSON) -> Bool {
        return json["in_reply_to_user_id_str"].string == store?.appState.setting.loginUser?.id
    }
}
