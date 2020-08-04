//
//  Model.swift
//  DataFlow
//
//  Created by jyrnan on 2020/7/10.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import SwiftUI
import SwifteriOS
import Combine

struct TweetMedia: Identifiable {
    var id: String
    
    var userName: String?
    var screenName: String?
    var userIDString: String?
    
    var avatarUrlString: String?
    var avatar: UIImage? = UIImage(systemName: "person.fill")
    
    var replyUsers: [String] = []
    var tweetText: [String] = []
    var created: String?
    
    var urlStrings: [String]?
    var images: [String: UIImage] = [:]
    
    var favorited: Bool = false
    var favoriteTimes: Int?
    
    var retweeted: Bool = false
    var retweetedTimes: Int?
    
    var retweeted_by_IDString: String?  //存储retweet本推文的推文ID
    var retweeted_by_UserIDString: String? //存储retweet本推文的用户ID
    var retweeted_by_UserName: String? //存储retweet本推文的用户名

    var in_reply_to_user_id_str : String?
    var in_reply_to_status_id_str: String?
    var replyText: String?
    
    var isToolsViewShowed: Bool = false //控制是否显示row里面的ToolsView
    
    var quoted_status_id_str: String? //引用推文的ID
    
    init(id: String) {
        self.id = id
    }
}

class CacheFileHandler : NSObject {
    let fm = FileManager.default
    func getPath() -> URL {
        var docsurl : [URL]
        docsurl = fm.urls(for: .cachesDirectory, in: .userDomainMask)
        return docsurl[0]
    }
}



struct Model_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
