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
    ///   - logHandler: 传入用来记录和输出信息的处理函数
    /// - Returns: <#description#>
    func deleteTweets(for userID: String , keepRecent: Bool = false, completeHandler: @escaping ()->(), logHandler: @escaping (String) -> ()) {
        
//        guard let windowsScenen = UIApplication.shared.connectedScenes.first as? UIWindowScene ,
//              let sceneDelegate = windowsScenen.delegate as? SceneDelegate
//        else { return }
        
        
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
                logHandler("No tweets deleted.")
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
            logHandler( "Deleting task failed.")
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
                logHandler("About \(deletedTweetCount) tweets deleted.")
                
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
        _ = getTimeNow()
        
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
    
//MARK:-快速删除推文方法
    
    /// 快速删除推文的方法，一次性删除较多数量的推文。
    /// 限于API限制，3小时内最多执行300次Post的操作，所以一次最多只能执行300条推文删除
    /// TODO：根据上次执行时间的间隔来确定本次推文删除动作可以设置的最大删除量
    /// - Parameters:
    ///   - userID: 用户ID
    ///   - willDeleteCount: 将要删除的数量，默认是300条
    ///   - keepRecent: 是否保留最新的推文不删除
    ///   - completeHandler: 删除成功后执行的闭包
    ///   - logHandler: 可以用来写入记录的闭包
    /// - Returns: nil
    func fastDeleteTweets(for userID: String ,willDeleteCount: Int? = nil, keepRecent: Bool = false, completeHandler: @escaping ()->(), logHandler: @escaping (String) -> () ) {
        
        //用来存储等待删除的推文ID
        var tweetsForDeletionIDStrings: [String] = []
        let userIDString = userID
        var maxIDString:String?
        
        //记录循环获取推文的次数。影响到推文获取总数
        var getTimes: Int = 0 //获取推文的次数
        var deletedTweetCount: Int = 0 //最终删除的推文数量
        
        func calManualDeleteCount() -> Int {
            var count: Int = 0
            let lastCleanDate = PersistenceContainer.getLastDeleted() ?? .distantPast
            
            let now = Date()
            let threeHours = TimeInterval(3 * 60 * 60)
            
            if now > (lastCleanDate + threeHours) {
                count = 300
            } else {
                count = Int(abs(lastCleanDate.timeIntervalSinceNow / threeHours) * 300.0)
            }
            
            return count
        }
        
        //如果没有传入需要删除的数量，则计算最大可以删除推文数量
        let willDeleteCount = willDeleteCount ?? calManualDeleteCount()
        print(#line, "可以删除\(willDeleteCount)条推文")
        
        /// 获取推文成功的处理闭包
        /// - Parameter json:
        /// - Returns:
        func getSh (json: JSON) -> () {
            
            let tweetsForDeletion = json.array ?? []
            guard !tweetsForDeletion.isEmpty else { return }
            
            //判断是否含有重复的推文ID，因为利用maxID来获取推文会在第一条和上一轮的最后一条重复
            //所以删除上一轮的最后一条
            if maxIDString != nil {
                tweetsForDeletionIDStrings.removeLast(1)
            }
            
            for tweet in tweetsForDeletion {
                if let idString = tweet["id_str"].string {
                    tweetsForDeletionIDStrings.append(idString)
                }
            }
            
            getTimes += 1 //获取推文次数加一
            
            //把本轮最后一条推文ID设置为maxIDString，用于下一轮获取推文的起始位置
            maxIDString = tweetsForDeletionIDStrings.last
            
            //获取推文的次数应该是4次即可，达到4次就开始处理推文
            if getTimes < 4 {
                self.getTimeline(for: UserTag.id(userIDString),
                                 count: 100,
                                 maxID: maxIDString,
                                 success:getSh(json:),
                                 failure: nil)
            } else {
                prepareTweetsForDeletion()
            }
        }
        
        /// 获取推文的函数，通过调用现在方法，在成功后就可以继续调用获取推文成功的处理闭包
        func getTweets() {
            self.getTimeline(for: UserTag.id(userIDString),
                             count: 100,
                             success:getSh(json:),
                             failure: nil)
        }
        
        
        /// 处理待删除推文ID序列
        func prepareTweetsForDeletion() {
            
            //处理是否需要保留最近的100条
            //如果超过100条则移除前100条
            //如果不足100条，则全部移除
            //所有移除的ID意味着不会在后续被删除
            if keepRecent {
                if tweetsForDeletionIDStrings.count >= 100 {
                    tweetsForDeletionIDStrings.removeFirst(100)
                } else {
                    tweetsForDeletionIDStrings.removeAll()
                }
            }
            
            //如果待删除的ID列表数量大于传入的删除数量，则移除超过的所有ID
            if tweetsForDeletionIDStrings.count >= willDeleteCount {
                tweetsForDeletionIDStrings.removeLast(tweetsForDeletionIDStrings.count - willDeleteCount)
            }
            
            
            //此时剩下的推文ID应该是需要被删除的，执行删除方法
            deleteTweets()
        }
        
        //TODO: 删除待删除推文ID列表里面的所有推文
        func deleteTweets() {
            
            //为每一条待删除推文分配一个删除任务
            //删除成功则在待删除推文ID列表中相应位置将ID替换成"success"
            //删除失败则在待删除推文ID列表中相应位置将ID替换成"failure"
            //每次调用success或failure都会在替换完成后
            //调用checkIsDeleteFinished()检查是不是所有任务都完成，如果完成则调用completeHandler()
            for i in 0..<tweetsForDeletionIDStrings.count {
                let idString = tweetsForDeletionIDStrings[i]
                swifter.destroyTweet(forID: idString, success: { _ in
                    tweetsForDeletionIDStrings[i] = "success"
                    
                    //更新最后删推时间
                    PersistenceContainer.updateLastDeleted()
                    
                    if checkIsDeleteFinished() {
                        
                        completeHandler()
                        let logText = "\(deletedTweetCount) tweets deleted."
                        logHandler(logText)
                    }
                }, failure: {error in
                    tweetsForDeletionIDStrings[i] = "failure"
                    print(error.localizedDescription)
                    if checkIsDeleteFinished() {
                        completeHandler()
                        let logText = "\(deletedTweetCount) tweets deleted."
                        logHandler(logText)
                    }
                })
                
                
            }
            
        }
        
        
        /// 判断所有删除任务是否执行完成。
        /// - Returns: 如果所有任务执行完成，则返回true
        func checkIsDeleteFinished() -> Bool{
            
            //如果tweetsForDeletionIDStrings所有IDString均被替换成"success"或"failure"
            //则表明所有的ID都被分配了删除任务并有了返回执行结果，只是删除也可能不成功
            let unDealedIDStrings = tweetsForDeletionIDStrings.filter{$0 != "success" && $0 != "failure"}
            
            let deletedIDString = tweetsForDeletionIDStrings.filter{$0 == "success"}
            deletedTweetCount = deletedIDString.count
            
            return unDealedIDStrings.isEmpty
            
        }
        
        //获取待删除推文，是程序的入口
        getTweets()
    }
    
    
   
}
