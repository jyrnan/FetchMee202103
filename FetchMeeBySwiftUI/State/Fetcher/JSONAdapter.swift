//
//  JSONAdapter.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/27.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Swifter

struct JSONAdapter {
    /// User信息转换的接口程序
    /// - Parameters:
    ///   - userInfo: 输入的初始用户信息
    ///   - json: 输入的用户原始数据
    /// - Returns: 输出的用户信息
    func convertAndUpdateUser(update userInfo: inout UserInfo, with json: JSON) {
        //        var userInfo = userInfo
        
        ///userBio信息更新开始
        userInfo.id = json["id_str"].string!
        userInfo.name = json["name"].string
        userInfo.screenName = json["screen_name"].string
        userInfo.description = json["description"].string
        userInfo.createdAt = json["created_at"].string //加入日期
        
        userInfo.avatarUrlString = json["profile_image_url_https"].string?
            .replacingOccurrences(of: "_normal", with: "")
        userInfo.bannerUrlString = json["profile_banner_url"].string
       
        userInfo.loc = json["location"].string
        userInfo.url = json["url"].string
        
        userInfo.following = json["friends_count"].integer
        userInfo.followed = json["followers_count"].integer
        userInfo.isFollowing = json["following"].bool
        userInfo.isFollowed = json["follow_request_sent"].bool
        
        userInfo.notifications = json["notifications"].bool
        
        userInfo.tweetsCount = json["statuses_count"].integer

    }
    
    func convertToStatus(from json: JSON) -> Status {
        var status = Status(id: json["id_str"].string!)
        
        var user = UserInfo()
        convertAndUpdateUser(update: &user, with: json["user"])
        status.user = user
        
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
    
}
