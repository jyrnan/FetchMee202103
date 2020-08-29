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
    
    var retweeted_by_IDString: String?  //存储retweet本推文的推文ID
    var retweeted_by_UserIDString: String? //存储retweet本推文的用户ID
    var retweeted_by_UserName: String? //存储retweet本推文的用户名
    
    var userName: String?
    var screenName: String?
    var userIDString: String?
    
    var avatarUrlString: String?
    var avatar: UIImage? = UIImage(systemName: "person.fill")
    
    var replyUsers: [String] = []
    var tweetText: [String] = []
    var created: String?
    
    var urlStrings: [String]? //图片的url
    var images: [UIImage] = [] //下载的UIImage
    
    var mediaType: String?
    var mediaUrlString: String? //视频网址
    
    var favorited: Bool = false
    var favorite_count: Int?
    
    var retweeted: Bool = false
    var retweet_count: Int?

    var in_reply_to_user_id_str : String?
    var in_reply_to_status_id_str: String?
    var replyText: String?
    
    var isToolsViewShowed: Bool = false //控制是否显示row里面的ToolsView
    
    var quoted_status_id_str: String? //引用推文的ID
    
    var rowIsViewed: Bool = false //用来标记推文是否出现在屏幕上被展现?
    
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
