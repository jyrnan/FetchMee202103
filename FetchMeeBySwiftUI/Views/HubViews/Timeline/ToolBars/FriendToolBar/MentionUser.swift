//
//  MentionUser.swift
//  FetchMee
//
//  Created by jyrnan on 11/5/20.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

class MentionUserSortedViewModel: ObservableObject {
    
    
    //记录用户互动mention推文信息（推文ID）数量,
    ///纪录顺序[userName, screenName, avatarUrlString, tweetID...tweetID]
    ///这个数据会被保存到本地
    var mentionUserData: [String:[String]] 
    
    @Published var mentionUserIDStringsSorted: [String] = []
    
    ///排序后生成的用户信息供调用。
    ///但是是否在这里实现还可以再考虑。是不是可以考虑在Mention的timeline同时保存用户信息到CoreData
    @Published var userInfos: [String:UserInfo] = [:]
    
    init() {
        self.mentionUserData = userDefault.object(forKey: "mentionUserData") as? [String:[String]] ?? [:] //读取数据
        makeMentionUserSortedList()
    }
    
    ///生成互动用户的排序列表并存储用户回复的用户和推文ID列表
    func makeMentionUserSortedList() {
        ///先保存当前的回复用户信息。
        userDefault.set(mentionUserData, forKey: "mentionUserData")
        ///按Mention数量照降序排序再生产排序的userIDString
        let mentionUserInfoSorted = mentionUserData.sorted{$0.value.count > $1.value.count}
        self.mentionUserIDStringsSorted = mentionUserInfoSorted.map{$0.key}
    }
    
}
