//
//  Counter+Calculate.swift
//  FetchMee
//
//  Created by jyrnan on 11/10/20.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import CoreData

struct CountValue {
    var followerOfLastDay: Int = 0
    var followerOfLastThreeDays: Int = 0
    var followerOfLastSevenDays: Int = 0
    
    var tweetsOfLastDay: Int = 0
    var tweetsOfLastThreeDays: Int = 0
    var tweetsOfLastSevenDays: Int = 0
}


extension Count {
    
    fileprivate static func valueCalculate(_ counts: [Count]?, for days: Double = 1.0) -> (Int, Int){
        var followers: Int = 0
        var tweets: Int = 0
        
        let daysAgo = Date().addingTimeInterval(-60 * 60 * 24 * days)
        
        let lastDayCounts = counts?.filter{$0.createdAt! > daysAgo}
        
        if let max = lastDayCounts?.max(by: {a, b in a.follower < b.follower}),
           let min = lastDayCounts?.min(by: {a, b in a.follower < b.follower}) {
            followers = Int(max.follower - min.follower)}
        
        if let max = lastDayCounts?.max(by: {a, b in a.tweets < b.tweets}),
           let min = lastDayCounts?.min(by: {a, b in a.tweets < b.tweets}) {
            tweets = Int((max.tweets - min.tweets))}
        
        return (followers, tweets)
    }
    
    static func updateCount(for user: UserInfo, in viewContext: NSManagedObjectContext) -> CountValue {
        //参数说明：第一个数组代表follower，第二个代表tweets数量
        //每类有三个数是预留最近一天，最近一周？最近一月？，现在仅使用第一个
        var countValue = CountValue()
        
        let userPredictate = NSPredicate(format: "%K == %@", #keyPath(Count.countToUser.userIDString), user.id)
        let countRequest:NSFetchRequest<Count> = Count.fetchRequest()
        countRequest.predicate = userPredictate
        
        let counts = try? viewContext.fetch(countRequest)
        
        
        countValue.followerOfLastDay = valueCalculate(counts, for: 1.0).0
        countValue.tweetsOfLastDay = valueCalculate(counts, for: 1.0).1
        return countValue
    }
}

