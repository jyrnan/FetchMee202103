//
//  AvatarViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/27.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import UIKit


class AvatarViewModel: User {
    
    let userIDString: String?
    let userName: String? //传入用户的名字
    let screenName: String? //传入用户的名字
    let tweetIDString: String? //传入该头像所在的推文ID
    let avatarUrlString: String //传入该头像Url
    
    
    init(userIDString: String?, avatarUrlString: String, userName: String? = nil, screenName: String? = nil, tweetIDString: String? = nil) {
        
        self.userIDString = userIDString
        self.avatarUrlString = avatarUrlString
        self.userName = userName
        self.screenName = screenName
        self.tweetIDString = tweetIDString
    }
}
