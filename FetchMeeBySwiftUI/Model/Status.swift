//
//  Model.swift
//  DataFlow
//
//  Created by jyrnan on 2020/7/10.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import SwiftUI
import Swifter
import Combine

struct Status: Identifiable {
    var id: String
   
    var userName: String?
    var screenName: String?
    var userID: String?
    
    var avatarUrl: String?
    
    var replyUsers: [String] = []
    var text: String?
    var createdAt: Date?
    
    var imageUrls: [String]? //图片的url
    
    var mediaType: String?
    var mediaUrlString: String? //视频网址
    
    var favorited: Bool = false
    var favorite_count: Int?
    
    var retweeted: Bool = false
    var retweet_count: Int?

    var in_reply_to_user_id_str : String?
    var in_reply_to_status_id_str: String?
    var replyText: String?
    var quoted_status_id_str: String? //引用推文的ID
    
    var isPortraitImage: Bool = false //标记推文是否含有人物图像
    var rowIsViewed: Bool = false //用来标记推文是否出现在屏幕上被展现?

    init(id: String) {
        self.id = id
    }
}

//class CacheFileHandler : NSObject {
//    let fm = FileManager.default
//    func getPath() -> URL {
//        var docsurl : [URL]
//        docsurl = fm.urls(for: .cachesDirectory, in: .userDomainMask)
//        return docsurl[0]
//    }
//}
