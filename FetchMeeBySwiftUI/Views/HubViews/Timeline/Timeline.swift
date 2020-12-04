//
//  Timeline.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import SwiftUI
import Swifter
import Combine
import Photos

final class Timeline: ObservableObject {
    @Published var tweetIDStrings: [String] = []
    @Published var imageURLStrings: [String: Bool] = [:] //标记被选择的图片ID???
    @Published var tweetMedias: [String: TweetMedia] = [:]
    @Published var newTweetNumber: Int = 0
    @Published var isDone: Bool = true { //设定在更新任务时候状态指示器是否显示，但无论任务是否结束，10秒种后状态指示器消失
        didSet {
            delay(delay: 10, closure: {
                if self.isDone  == false {
                    self.isDone = true
                }
            })
        }
    }
    
    ///存储根据MentiUserinfo情况排序的UserIDString
    @Published var mentionUserIDStringsSorted: [String] = []
    @Published var userInfos: [String : UserInfo] = [:] //存储UserInfo供调用
    ///记录用户互动mention推文信息（推文ID）数量,
    ///纪录顺序[userName, screenName, avatarUrlString, tweetID...tweetID]
    ///这个数据会被保存到本地
    var mentionUserInfo: [String:[String]] = [:]
    
    @Published var selectedImageCount: Int = 0
    
    
    var tweetRowViewModels: [String: TweetRowViewModel] = [:]
    
    var type: TimelineType
    var listTag: ListTag? // 如果是list类型，则会传入listTag
    @Published var tweetIDStringOfRowToolsViewShowed: String? //显示ToolsView的推文ID
    
    let session = URLSession.shared
    let maxCounter: Int = 100
    var sinceIDString: String?
    var maxIDString: String?
    
    init(type: TimelineType, listTag: ListTag? = nil) {
        self.type = type
        self.listTag = listTag
        print(#line, "timeline(\(self.type)) init", self)
        switch type {
        case .session:
            print()
        case .mention:
            self.mentionUserInfo = userDefault.object(forKey: "mentionUserInfo") as? [String:[String]] ?? [:] //读取数据
            self.makeMentionUserSortedList()//初始化更新MentionUser排序
        default:
            print()
        }
    }
    
    deinit {
        
        switch type {
        case .mention:
            print(#line, self.mentionUserInfo.count)
        default:
            print(#line, "Timeline \(self.type) disappeared!" ,#function)
        }
    }
    
    //MARK: - 更新推文函数
    ///更新上方推文
    func refreshFromTop(for userIDString: String? = nil, completeHandeler:(() -> Void)? = nil ,fh: ((Error) -> Void)? = nil) {
        func sh(json: JSON) ->Void {
            let newTweets = json.array ?? []
            self.newTweetNumber += newTweets.count
            
            ///MVVM
            newTweets.forEach{StatusRepository.shared.addStatus($0)}
            ///MVVM END
           
            self.updateTimelineTop(with: newTweets)
            self.isDone = true
            self.makeMentionUserSortedList() //存储MentionUserInfo并更新MentionUser的排序
            
            //用于设置后台刷新完成时调用setTaskCompleted(success: true)
            guard completeHandeler != nil else {
                return
            }
            completeHandeler!()
        }
        
        let failureHandler: ((Error) -> Void)? = fh
        
        switch self.type {
        case .mention:
            swifter.getMentionsTimelineTweets(count: self.maxCounter, sinceID: self.sinceIDString, success: sh, failure: failureHandler)
        case .home:
            swifter.getHomeTimeline(count: self.maxCounter, sinceID: self.sinceIDString,  success: sh, failure: failureHandler)
        case .user:
            swifter.getTimeline(for: UserTag.id(userIDString ?? "0000"), success: sh, failure: failureHandler)
        case .favorite:
            swifter.getRecentlyFavoritedTweets(success: sh, failure: failureHandler)
        case .list:
            if let listTag = listTag {
                swifter.listTweets(for: listTag, sinceID: self.sinceIDString, maxID: self.maxIDString, count: self.maxCounter, includeEntities: nil, includeRTs: nil, tweetMode: .default, success: sh, failure: failureHandler)
            }
            
        default:
            print(#line, #function)
        }
    }
    
    
    ///从推文下方开始更新
    func refreshFromBottom(for userIDString: String? = nil) {
        func sh(json: JSON) ->Void {
            let newTweets = json.array ?? []
            
            self.isDone = true
            self.updateTimelineBottom(with: newTweets)
            self.isDone = true
            self.makeMentionUserSortedList() //存储MentionUserInfo并更新MentionUser的排序
        }
        
        let failureHandler: (Error) -> Void = { error in
            print(#line, error.localizedDescription)}
        
        switch self.type {
        case .mention:
            self.isDone = false
            swifter.getMentionsTimelineTweets(count: self.maxCounter, maxID: self.maxIDString, success: sh, failure: failureHandler)
        case .home:
            self.isDone = false
            swifter.getHomeTimeline(count: self.maxCounter,maxID: self.maxIDString,  success: sh, failure: failureHandler)
        case .user:
            swifter.getTimeline(for: UserTag.id(userIDString ?? "0000"), count: self.maxCounter, maxID: self.maxIDString, success: sh, failure: failureHandler)
         
        case .favorite:
            swifter.getRecentlyFavoritedTweets(count: self.maxCounter, maxID: self.maxIDString, success: sh, failure: failureHandler)
        default:
            print(#line, #function)
        }
    }
    /**
     
     -parameter newTweets: 接受一个来自
     */
    func updateTimelineTop(with newTweets: [JSON]) {
        guard !newTweets.isEmpty else {return}
        let newTweetIDStrings = converJSON2TweetDatas(from: newTweets)
        self.sinceIDString = newTweetIDStrings.first //获取新推文的第一条，作为下次刷新的起始点
        if self.tweetIDStrings.isEmpty {
            self.maxIDString = newTweetIDStrings.last //如果是全新刷新，则需要设置maxIDstring，以保证今后刷新下部推文会从当前最后一条开始。
        }
        
        self.tweetIDStrings = newTweetIDStrings + self.tweetIDStrings
    }
    
    func updateTimelineBottom(with newTweets: [JSON]) {
        guard !newTweets.isEmpty else {return}
        let newTweetIDStrings = converJSON2TweetDatas(from: newTweets)
        self.maxIDString = newTweetIDStrings.last //获取新推文的最后一条，作为下次刷新的起始点
        
        self.tweetIDStrings = self.tweetIDStrings.dropLast() + newTweetIDStrings //需要丢掉原来最后一条推文，否则会重复
    }
    
    /**
     转换JSON格式推文数据成本地数据模型转换JSON格式推文数据成本地数据模型，生成相应推文的Media数据结构
     并返回对应推文数据库的推文IDString列表
     
     - Parameter newTweets: 输入一个包含各个推文内容的JSON的数列，是通过Swifter实例的方法从服务器获得
    
     - returns: 返回一个有推文ID字符串组成的数列
     */
    func  converJSON2TweetDatas(from newTweets: [JSON]) -> [String] {
        
        /**
         转换单个推文JSON数据成TweetData，内置函数，传入的IDString用来生成并索引推文数据，有可能是原推文ID，但是也有可能是转推推文的ID
         */
        func converJson2TweetData(from newTweet: JSON, at IDString: String) {
            
            //生产对应推文的媒体数据字典，根据推文IDString或者转推推文IDString进行索引
            var tweetMedia = TweetMedia(id: newTweet["id_str"].string ?? "0000")
            
            tweetMedia.userIDString = newTweet["user"]["id_str"].string
            tweetMedia.userName = newTweet["user"]["name"].string
            tweetMedia.screenName = newTweet["user"]["screen_name"].string
            
            tweetMedia.replyUsers = self.convertTweetText(from: newTweet["text"].string).0
            tweetMedia.tweetText = self.convertTweetText(from: newTweet["text"].string).1
            
            tweetMedia.avatarUrlString = newTweet["user"]["profile_image_url_https"].string
            tweetMedia.avatarUrlString = tweetMedia.avatarUrlString?.replacingOccurrences(of: "_normal", with: "")
            tweetMedia.avatar = UIImage(systemName: "person.fill")
            
            //图片数据处理
            if newTweet["extended_entities"]["media"].array?.count != nil {
                let count: Int = newTweet["extended_entities"]["media"].array!.count
                
                tweetMedia.urlStrings = [String]()
                for m in 0..<count {
                    let urlstring = newTweet["extended_entities"]["media"][m]["media_url_https"].string!
            
                    tweetMedia.urlStrings?.append(urlstring)
                    tweetMedia.images.append(UIImage(named: "defaultImage")!) //先设置占位
                    tweetMedia.imagesSelected.append(false) //增加一个选择标记
                }
            }
            
            //视频数据处理
            if newTweet["extended_entities"]["media"].array?.count != nil &&
                newTweet["extended_entities"]["media"].array?.first?["type"] == "video" {
                tweetMedia.mediaType = "video"
                tweetMedia .mediaUrlString = newTweet["extended_entities"]["media"].array?.first?["video_info"]["variants"].array?.first?["url"].string
                
            }
            
            //GIF数据处理
            if newTweet["extended_entities"]["media"].array?.count != nil &&
                newTweet["extended_entities"]["media"].array?.first?["type"] == "animated_gif" {
                tweetMedia.mediaType = "animated_gif"
                tweetMedia .mediaUrlString = newTweet["extended_entities"]["media"].array?.first?["video_info"]["variants"].array?.first?["url"].string
                
            }
            
            tweetMedia.retweeted = newTweet["retweeted"].bool ?? false
            tweetMedia.retweet_count = newTweet["retweet_count"].integer ?? 0
            tweetMedia.favorited = newTweet["favorited"].bool ?? false
            tweetMedia.favorite_count = newTweet["favorite_count"].integer ?? 0
            
            tweetMedia.created = newTweet["created_at"].string
            
            tweetMedia.in_reply_to_user_id_str = newTweet["in_reply_to_user_id_str"].string
            tweetMedia.in_reply_to_status_id_str = newTweet["in_reply_to_status_id_str"].string
            
            //添加回复用户信息
            ///为了确保
            if self.type == .mention {
                guard let userIDString = newTweet["user"]["id_str"].string else {return}
                let userName = newTweet["user"]["name"].string ?? "Name"
                let screenName = newTweet["user"]["screen_name"].string ?? "ScreeName"
                let avatarUrlString = newTweet["user"]["profile_image_url_https"].string?
                    .replacingOccurrences(of: "_normal", with: "") ?? ""
                let tweetID = newTweet["in_reply_to_status_id_str"].string ?? ""
                
                ///如果新的Mention用护，则按照格式创建一个用户数据
                if self.mentionUserInfo[userIDString] == nil {
                    self.mentionUserInfo[userIDString] = [userName, screenName, avatarUrlString, tweetID]
                } else {
                    ///如果该用户存在，且该推文是该用户新回复，则将推文ID添加至尾端
                    if self.mentionUserInfo[userIDString]?.contains(tweetID) == false {
                        self.mentionUserInfo[userIDString]?.append(tweetID)
                    }
                }
            }
            
            self.tweetMedias[IDString] = tweetMedia
        }
        
        
        let newTweets = newTweets
        var newTweetIDStrings = [String]()
        
        for i in newTweets.indices {
            let newTweet = newTweets[i]
            
            guard let IDString = newTweet["id_str"].string else {return newTweetIDStrings}

            if newTweet["retweeted_status"]["id_str"].string != nil { //这个判断也是醉了。没找到好的方法，判断retweeted_status是否有实际内容。如果不是"<INVALID JSON>"，则表示是正确的Retweet推文内容，执行下面的操作生成retweeted_status的数据，否则是正常的推文，跳转到下面继续执行。
                let retweeted_by_UserIDString = newTweet["user"]["id_str"].string
                let retweeted_by_UserName = newTweet["user"]["name"].string
                let retweeted_status = newTweet["retweeted_status"] //把原推文里面的被转推推文内容提取出来
                    newTweetIDStrings.append(IDString) //还是应该插入原转推推文的ID作为索引
                    converJson2TweetData(from: retweeted_status, at: IDString) //传入的是原转推推文的ID，用来生成对应的推文数据文件。但内容其实是被转推推文的内容。
                    ///下面是转换被转推推文内容成推文数据文件的基础上再补充原转推推文的部分信息，用于显示
                    self.tweetMedias[IDString]?.retweeted_by_IDString = IDString
                    self.tweetMedias[IDString]?.retweeted_by_UserIDString = retweeted_by_UserIDString
                        self.tweetMedias[IDString]?.retweeted_by_UserName = retweeted_by_UserName
            } else {
            
            newTweetIDStrings.append(IDString)
            converJson2TweetData(from: newTweet, at: IDString)
            
            ///处理引用的推文
            if let quoted_status_id_str = newTweet["quoted_status_id_str"].string { //判断是否含有引用推文
                self.tweetMedias[IDString]?.quoted_status_id_str = quoted_status_id_str //如果含有引用推文，则把引用推文的ID添加到ID数据组中
                let quoted_status = newTweet["quoted_status"] as JSON //剥离推文数据中包含的引用推文数据
                converJson2TweetData(from: quoted_status, at: quoted_status_id_str ) //将剥离的引用推文数据转换成和引用推文ID对应的推文数据
            }
        }
        }
        return newTweetIDStrings 
    }
    
    
    /**
     把回复用户名从推文中分离出来
     */
    func convertTweetText(from originalTweetText: String?) -> ([String], [String]) {
        var replyUsers: [String] = []
        var tweetText: [String] = []
        guard originalTweetText != nil else{return (replyUsers, tweetText)}
        tweetText = originalTweetText!.split(separator: " ").map{String($0)}
        
        for string in tweetText {
            if string.first != "@" {
                break
            }
            replyUsers.append(string)
        }
        if !replyUsers.isEmpty {
            tweetText.removeFirst(replyUsers.count)
        }
        return (replyUsers, tweetText)
    }

    /**通用的image下载程序
     - Parameter urlString: 传入的下载地址
     - Parameter sh: 传入的闭包用来执行操作，往往用来赋值给数据
     */
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
//                DispatchQueue.main.async {
                    sh(im)
                
            }
        } else { //
            let task = self.session.downloadTask(with: url) {
                fileURL, resp, err in
                if let url = fileURL, let d = try? Data(contentsOf: url) {
                    if let im = UIImage(data: d) {
                    try? d.write(to: filePath)
//                    DispatchQueue.main.async {
                        sh(im)
//                    }
                        
                    }
                }
            }
            task.resume()
        }
    }
    
    /// 一个用来下载视频的代码，下载后会把视频文件保存的手机的相册，期间会在app的暂存位置保存，名字为timpFile.mp4
    /// - Parameters:
    ///   - urlString: 视频的url地址
    ///   - sh: 视频存储成功后执行的闭包
    ///   - fh: 视频存储失败时执行的闭包
    /// - Returns: 没有返回值。其结果的处理应该在sh或者fh里面实现
    func videoDownloader(from urlString: String?, sh:@escaping ()->Void, fh:@escaping ()->Void ) -> Void {
        if let urlString = urlString {

        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: urlString),
                let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/tempFile.mp4"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }){ completed, error in
                        if completed {
                           
                            DispatchQueue.main.async{sh()}
                        }
                        if error != nil {
                            fh()
                        }
                    }
                }
            }
        }
    }
    }
}

extension Timeline {
    func getReplyDetail(for idString: String) {
        self.isDone = false
        let failureHandler: (Error) -> Void = { error in
            print(#line, error.localizedDescription)}
        
        var counter: Int = 0
        
        func finalReloadView() {
            //最后操作，可能需要
            self.isDone = true
          
        }
        func sh(json: JSON) -> () {
            let newTweets = [json]
            let newTweetIDStrings = converJSON2TweetDatas(from: newTweets)
            self.tweetIDStrings = newTweetIDStrings + self.tweetIDStrings
            if let in_reply_to_status_id_str = json["in_reply_to_status_id_str"].string, counter < 8 {
                swifter.getTweet(for: in_reply_to_status_id_str, success: sh, failure: failureHandler)
                counter += 1
            } else {
                finalReloadView()
            }
        }
        swifter.getTweet(for: idString, success: sh, failure: failureHandler)
    }
}

extension Timeline {
    
    ///生成互动用户的排序列表并存储用户回复的用户和推文ID列表
    func makeMentionUserSortedList() {
        
        guard self.type == .mention else {return}
        ///先保存当前的回复用户信息。
        userDefault.set(self.mentionUserInfo, forKey: "mentionUserInfo")
        
        let mentionUserInfoSorted = self.mentionUserInfo.sorted{$0.value.count > $1.value.count} //按Mention数量照降序排序
        
        self.mentionUserIDStringsSorted = []
        
        for user in mentionUserInfoSorted {
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
                self.imageDownloaderWithClosure(from: userInfo.avatarUrlString, sh: { im in
                    DispatchQueue.main.async {
                        self.userInfos[userIDString]?.avatar = im
                    }
                })
                self.userInfos[userIDString] = userInfo
            }
        }
    }
}

//MARK:- 增加删推功能
extension Timeline {
    func deleteAllTweets(userID: String) {
        guard self.type == .user else {return}
        self.refreshFromTop()
        guard self.tweetIDStrings.isEmpty else {return}
    }
    
    func clearTimeline() {
        self.tweetIDStrings.removeAll()
        self.imageURLStrings.removeAll()
        self.tweetMedias.removeAll()
    }
}


extension Timeline {
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

struct Timeline_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}

extension Timeline {
    func getTweetViewModel(tweetIDString: String) -> TweetRowViewModel {
        if let tweetRowViewModel = tweetRowViewModels[tweetIDString] {
            return tweetRowViewModel
        } else {
            return makeTweetRowViewModel(tweetIDString: tweetIDString)
        }
    }
    
    func makeTweetRowViewModel(tweetIDString: String) ->TweetRowViewModel {
        let tweetRowViewModel = TweetRowViewModel(timeline: self, tweetIDString: tweetIDString)
        tweetRowViewModels[tweetIDString] = tweetRowViewModel
        return tweetRowViewModel
    }
    
    
}
