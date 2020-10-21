//
//  Swifter+Observable.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/15.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine

extension Swifter {
    
    
    /// 用于后台删除推文的方法。结合每次执行时间是15分钟，所以每次删除20条推文比较合适
    /// - Parameters:
    ///   - userID: 要删除推文的用户ID
    ///   - keepRecent: 删除推文时是否保留最新的80条推文，保留数量留到后期可以进一步设置
    ///   - completeHandler: 传入作为所有任务全部完成后的成功回调，主动通知系统后台任务可以结束
    /// - Returns: <#description#>
    func deleteTweets(for userID: String , keepRecent: Bool = false, completeHandler: @escaping ()->()) {
        
        guard let windowsScenen = UIApplication.shared.connectedScenes.first as? UIWindowScene ,
              let sceneDelegate = windowsScenen.delegate as? SceneDelegate
        else { return }
        
        
        //3 准备好待删除的推文的方法
        func prepareTweetsForDeletion(json: JSON) {
            var tweetsForDeletion = json.array ?? []
            
            if keepRecent {
            //如果超过80个，则去除前80个以不被删除
            if tweetsForDeletion.count >= 80 {
                tweetsForDeletion.removeFirst(80)}
            else {
                tweetsForDeletion.removeAll()
            }
            
            }
            //如果要删除的推文数量为零，则直接退出并输出信息
            guard !tweetsForDeletion.isEmpty else {
                sceneDelegate.alerts.logInfo.alertText = "<\(timeNow)> No tweets deleted."
                sceneDelegate.saveOrUpdateLog(text: "No tweets deleted.")
                return
            }
            
            //记录将要删除的推文数量
            deletedTweetCount = tweetsForDeletion.count
            
            //把需要删除的推文id提取出来添加到删除队列tweetsTobeDel
            for tweet in tweetsForDeletion {
                if let idString = tweet["id_str"].string {
                    tweetsTobeDel.append(idString)
                }
            }
        }
        
        func fh(error: Error) -> Void {
            sceneDelegate.alerts.logInfo.alertText = "<\(timeNow)> Deleting task failed."
            sceneDelegate.saveOrUpdateLog(text: "Deleting task failed.")
        }
        
        //2 获取推文成功处理闭包，成功后会调用删除推文方法
        func getSH(json: JSON) -> Void {
           prepareTweetsForDeletion(json: json)
            
            //4开始删除推文。
            //下面的判断必须要。因为tweetsTobeDel有可能为空，不会执行删推方法，
            //所以需要调用completeHandler，并返回结束
            guard !tweetsTobeDel.isEmpty else {
                completeHandler()
                return}
            
            let tweetWillDel = tweetsTobeDel.removeLast()
            swifter.destroyTweet(forID: tweetWillDel, success: delSH(json:), failure: fh)
        }
        
        func delSH(json: JSON) -> Void {
            //这里判断如果所有需要被删除的推文都已经完成，则可以调用最终的completeHandler
            guard !tweetsTobeDel.isEmpty else {
                
                //传递文字并保存到Draft的CoreData数据中
                sceneDelegate.alerts.logInfo.alertText = "About \(deletedTweetCount) tweets deleted."
                sceneDelegate.saveOrUpdateLog(text: "About \(deletedTweetCount) tweets deleted.")
                
                completeHandler()
                return
            }
            
            let tweetWillDel = tweetsTobeDel.removeLast()
            swifter.destroyTweet(forID: tweetWillDel, success: delSH(json:))
        }
        
        
        /// 获取当前的时间
        /// - Returns: 当前时间的字串
        func getTimeNow() -> String {
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .long
            formatter.timeZone = .current
            let timeNow = formatter.string(from: now)
            return timeNow
        }
        
        //1 这里是方法的真正入口
        //先获取SceneDelegate
        let timeNow = getTimeNow()
        
        var tweetsTobeDel: [String] = [] //将要删除的推文的id序列
        var deletedTweetCount: Int = 0 //将要删除的推文数量
        let userIDString = userID
        
        //一次读取推文数量，该值决定了保留最新推文的数量，保留推文数量设置默认为80条，所以最多读取100条
        let maxCount: Int = {
            switch keepRecent {
            case true:
                return 100
            case false:
                return 20
            }
        }()
        
        self.getTimeline(for: UserTag.id(userIDString ),
                            count: maxCount,
                            success: getSH,
                            failure: fh)
    }
   
}
