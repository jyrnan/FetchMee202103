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
    var id: String = UUID().uuidString
    var user: User? = User()

    var text: String = "The status text unavaliable"
    var attributedString: AttributedString = AttributedString("The status text unavaliable")
    var createdAt: Date = Date()
    
    var imageUrls: [String]? //图片的url
    
    var mediaType: String?
    var mediaUrlString: String? //视频网址
    
    var favorited: Bool = false
    var favorite_count: Int = 0
    
    var retweeted: Bool = false
    var retweet_count: Int = 0
    
    var retweeted_status_id_str: String?
    var quoted_status_id_str: String? //引用推文的ID
    

    var in_reply_to_user_id_str : String?
    var in_reply_to_status_id_str: String?
    
    var source: String = "N/A"
    
    
    var isPortraitImage: Bool = false //标记推文是否含有人物图像
    var isRead: Bool = false //用来标记推文是否出现在屏幕上被展现?
    
    var isMentioned: Bool = false
    
}



