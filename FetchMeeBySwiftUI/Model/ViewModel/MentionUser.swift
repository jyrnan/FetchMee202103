//
//  MentionUser.swift
//  FetchMee
//
//  Created by jyrnan on 11/5/20.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

class MentionUser: ObservableObject {
    
    
    //记录用户互动mention推文信息（推文ID）数量,
    ///纪录顺序[userName, screenName, avatarUrlString, tweetID...tweetID]
    ///这个数据会被保存到本地
    var mentionUserData: [String:[String]]
    
    @Published var mentionUserIDStringsSorted: [String] = []
    
    ///排序后生成的用户信息供调用。
    ///但是是否在这里实现还可以再考虑。是不是可以考虑在Mention的timeline同时保存用户信息到CoreData
    @Published var userInfos: [String:UserInfo] = [:]
    
    init() {
        self.mentionUserData = userDefault.object(forKey: "mentionUserInfo") as? [String:[String]] ?? [:] //读取数据
        makeMentionUserSortedList()
    }
    
    func makeMentionUserSortedList() {
        
        let mentionUserDataSorted = self.mentionUserData.sorted{$0.value.count > $1.value.count} //按Mention数量照降序排序
        
        self.mentionUserIDStringsSorted = []
        
        for user in mentionUserDataSorted {
            let userIDString = user.key //用户的ID信息
            let userName = user.value[0] //第一个值是Name,下面类推
            let screenName = user.value[1]
            let avatarUrlString = user.value[2]
            
            ///将回复用户排序后添加到数据中
            self.mentionUserIDStringsSorted.append(userIDString)
            
            if self.userInfos[userIDString] == nil {
                var userInfo = UserInfo(id: userIDString)
                userInfo.name = userName
                userInfo.screenName = screenName
                userInfo.avatarUrlString = avatarUrlString
                userInfo.avatar = UIImage(systemName: "person.fill")
                
                self.userInfos[userIDString] = userInfo
                
                self.imageDownloaderWithClosure(from: userInfo.avatarUrlString, sh: { im in
                    DispatchQueue.main.async {
                        self.userInfos[userIDString]?.avatar = im
                    }
                })
            }
        }
    }
    func imageDownloaderWithClosure(from urlString: String?, sh: @escaping (UIImage) -> Void ){
        ///利用这个闭包传入需要的操作，例如赋值
        ///为了通用，取消了传入闭包在主线程运行的设置，所以需要在各自闭包里面自行设置UI相关命令在主线程执行
        let sh: (UIImage) -> Void = sh
        
        guard urlString != nil  else {return}
        guard let url = URL(string: urlString!) else { return}
        let fileName = url.lastPathComponent ///获取下载文件名用于本地存储
        
        let cachelUrl = cfh.getPath()
        let filePath = cachelUrl.appendingPathComponent(fileName, isDirectory: false)
        
        ///先尝试获取本地缓存文件
        if let d = try? Data(contentsOf: filePath) {
            if let im = UIImage(data: d) {
                sh(im)
            }
        } else { //
            let task = URLSession.shared.downloadTask(with: url) {
                fileURL, resp, err in
                if let url = fileURL, let d = try? Data(contentsOf: url) {
                    if let im = UIImage(data: d) {
                        try? d.write(to: filePath)
                        sh(im)
                    }
                }
            }
            task.resume()
        }
    }
}
