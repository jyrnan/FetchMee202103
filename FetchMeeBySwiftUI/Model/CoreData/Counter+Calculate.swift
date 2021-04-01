//
//  Counter+Calculate.swift
//  FetchMee
//
//  Created by jyrnan on 11/10/20.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import CoreData

//struct CountValue: Identifiable {
//    var  id = UUID()
//    
//    
//    var followerOfLastDay: Int = 0
//    var followerOfLastThreeDays: Int = 0
//    var followerOfLastSevenDays: Int = 0
//    
//    var tweetsOfLastDay: Int = 0
//    var tweetsOfLastThreeDays: Int = 0
//    var tweetsOfLastSevenDays: Int = 0
//}


extension Count {
    
    fileprivate static func valueCalculate(_ counts: [Count]?, for days: Double = 1.0) -> (Int, Int){
        var followers: Int = 0
        var tweets: Int = 0
        
        let daysAgo = Date().addingTimeInterval(-60 * 60 * 24 * days)
        let daysMinusOne = Date().addingTimeInterval(-60 * 60 * 24 * (days - 1))
        
        let lastDayCounts = counts?.filter{daysMinusOne > $0.createdAt! && $0.createdAt! > daysAgo}
        
        if let max = lastDayCounts?.max(by: {a, b in a.follower < b.follower}),
           let min = lastDayCounts?.min(by: {a, b in a.follower < b.follower}) {
            followers = Int((max.follower - min.follower) )}
        
        if let max = lastDayCounts?.max(by: {a, b in a.tweets < b.tweets}),
           let min = lastDayCounts?.min(by: {a, b in a.tweets < b.tweets}) {
            tweets = Int((max.tweets - min.tweets))}
        
        return (followers, tweets)
    }
    
    static func updateCount(for user: UserInfo, in viewContext: NSManagedObjectContext = PersistenceContainer.shared.container.viewContext) -> (followers:[Int], tweets: [Int]) {
        //参数说明：第一个数组代表follower，第二个代表tweets数量
        //每类有三个数是预留最近一天，最近一周？最近一月？，现在仅使用第一个
//        var countValue = CountValue()
        var followers: [Int] = []
        var tweets: [Int] = []
        
        let userPredictate = NSPredicate(format: "%K == %@", #keyPath(Count.countToUser.userIDString), user.id)
        let countRequest:NSFetchRequest<Count> = Count.fetchRequest()
        countRequest.predicate = userPredictate
        
        let counts = try? viewContext.fetch(countRequest)
        
        let _ = (1...28).map{day in
            let count = valueCalculate(counts, for: Double(day))
            followers.append(count.0)
            tweets.append(count.1)
        }
    
        
        print((followers:followers, tweets: tweets))
        return (followers:followers, tweets: tweets)
        
    }
    
    static func cleanCountData(success: () -> (), before days: Double, context: NSManagedObjectContext) {
        let daysInterval: TimeInterval = -(60 * 60 * 28 * days)
        let daysBefore = Date().addingTimeInterval(daysInterval)
        
        let timeIntervalPredicate: NSPredicate = NSPredicate(format: "%K <= %@", #keyPath(Count.createdAt), daysBefore as CVarArg)
        let fetchRequest: NSFetchRequest = Count.fetchRequest()
        fetchRequest.predicate = timeIntervalPredicate
        
        do {
            let counts = try context.fetch(fetchRequest)
            
            counts.forEach{context.delete($0)}
            
            try context.save()
            
            success()
        } catch let error as NSError {
            print("count not fetched \(error), \(error.userInfo)")
        }
    }
}

