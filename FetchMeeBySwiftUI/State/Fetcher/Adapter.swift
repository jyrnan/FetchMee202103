//
//  Adapter.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/27.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Swifter

struct Adapter {
    /// User信息转换的接口程序
    /// - Parameters:
    ///   - user: 输入的初始用户信息
    ///   - json: 输入的用户原始数据
    /// - Returns: 输出的用户信息
//    func convertAndUpdateUser(update user: inout User, with data: JSON) {
//
//        ///userBio信息更新开始
//        user.id = data["id_str"].string!
//        user.name = data["name"].string!
//        user.screenName = data["screen_name"].string!
//        user.description = data["description"].string ?? ""
//        user.createdAt = convertToDate(from:data["created_at"].string) ?? Date() //加入日期
//
//        user.avatarUrlString = data["profile_image_url_https"].string?
//            .replacingOccurrences(of: "_normal", with: "") ?? ""
//        user.bannerUrlString = data["profile_banner_url"].string ?? ""
//
//        user.loc = data["location"].string
//        user.url = data["url"].string
//
//        user.following = data["friends_count"].integer!
//        user.followed = data["followers_count"].integer!
//        user.isFollowing = data["following"].bool!
//        user.isFollowed = data["follow_request_sent"].bool!
//
//        user.notifications = data["notifications"].bool!
//
//        user.tweets = data["statuses_count"].integer!
//
//    }
//
//    func convertUserCDToUser(userCD: UserCD) -> User {
//        var user = User()
//
//        user.id = userCD.userIDString!
//        user.name = userCD.name!
//        user.screenName = userCD.screenName!
//        user.createdAt = userCD.createdAt!
//
//        user.avatarUrlString = userCD.avatarUrlString!
//        user.bannerUrlString = userCD.bannerUrlString ?? ""
//
//        user.bioText = userCD.bioText ?? ""
//        user.loc = userCD.loc
//        user.url = userCD.url
//
//        user.following = Int(userCD.following)
//        user.followed = Int(userCD.followed)
//        user.isFollowing = userCD.isFollowing
//        user.isFollowed = userCD.isFollowed
//
//        user.notifications = false
//
//        user.tweets = Int(userCD.tweets)
//
//        return user
//
//    }
    
    
    /// 利用（获取的）数据来更新CoreData的用户数据
    /// - Parameters:
    ///   - userCD:待更新的CoreData的用户数据
    ///   - data: 传入的数据
    func updateUserCD(_ userCD: UserCD, with data:JSON) {
        ///设置TwitterUser
        userCD.createdAt = convertToDate(from: data["created_at"].string)
        
        userCD.userIDString = data["id_str"].string!
        userCD.name = data["name"].string!
        userCD.screenName = data["screen_name"].string!
        
        userCD.avatarUrlString = data["profile_image_url_https"].string!
        userCD.bannerUrlString = data["profile_banner_url"].string ?? ""
        
        userCD.bioText = data["description"].string
        userCD.loc = data["location"].string
        userCD.url = data["url"].string
        
        userCD.following = Int32(data["friends_count"].integer ?? 0)
        userCD.followed = Int32(data["followers_count"].integer ?? 0)
        userCD.isFollowing = data["following"].bool ?? false
        userCD.isFollowed = data["follow_request_sent"].bool ?? false
        
        userCD.notification = data["notifications"].bool!
        userCD.tweets = Int32(data["statuses_count"].integer ?? 0)
    }
    
   
    
    func convertToStatus(from json: JSON) -> Status {
        var status = Status(id: json["id_str"].string!)
        
//        var user = User()
//        convertAndUpdateUser(update: &user, with: json["user"])
        status.user = UserCD.updateOrSaveToCoreData(from: json["user"], dataHandler: updateUserCD(_:with:)).convertToUser()
        
        
        status.text = json["text"].string ?? ""
        status.attributedText = json.getAttributedText()
        status.createdAt = convertToDate(from: json["created_at"].string) ?? Date()
        
        status.imageUrls = getImageUrls(from: json) //图片的url
        
        status.mediaType = json["extended_entities"]["media"].array?.first?["type"].string
        status.mediaUrlString = json["extended_entities"]["media"].array?.first?["video_info"]["variants"].array?.first?["url"].string
        
        status.favorited = json["favorited"].bool!
        status.favorite_count = json["favorite_count"].integer!
        
        status.retweeted = json["retweeted"].bool!
        status.retweet_count = json["retweet_count"].integer!
        
        status.retweeted_status_id_str = json["retweeted_status"]["id_str"].string
        status.quoted_status_id_str = json["quoted_status_id_str"].string //引用推文的ID

        status.in_reply_to_user_id_str = json["in_reply_to_user_id_str"].string
        status.in_reply_to_status_id_str = json["in_reply_to_status_id_str"].string
        
        status.source = json["source"].string!
        
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
