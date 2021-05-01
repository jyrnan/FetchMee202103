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
    
    static func updateCount(for userID: String, in viewContext: NSManagedObjectContext = PersistenceContainer.shared.container.viewContext) -> (followers:[Int], tweets: [Int]) {
        //参数说明：第一个数组代表follower，第二个代表tweets数量
        //每类有三个数是预留最近一天，最近一周？最近一月？，现在仅使用第一个
//        var countValue = CountValue()
        var followers: [Int] = []
        var tweets: [Int] = []
        
        let userPredictate = NSPredicate(format: "%K == %@", #keyPath(Count.countToUser.userIDString), userID)
        let countRequest:NSFetchRequest<Count> = Count.fetchRequest()
        let countSortDescriptors = [NSSortDescriptor(keyPath: \Count.createdAt, ascending: true)]
        countRequest.predicate = userPredictate
        countRequest.sortDescriptors = countSortDescriptors
        
        let counts = try? viewContext.fetch(countRequest)
        
        func isValidDate(date:Date, day: Int) -> Bool {
            let interval = Date().timeIntervalSince1970
            let intervalOfOneDay: Double = 60 * 60 * 24
            let intervalOfToday = Double(Int(interval) % Int(intervalOfOneDay))
            
            let daysNumber: Double = Double(day)
            let beginInterval: Date = Date().addingTimeInterval(-(intervalOfToday + daysNumber * intervalOfOneDay ))
            let endInterval: Date = beginInterval.addingTimeInterval(Double(intervalOfOneDay))
            
            return date >= beginInterval && date <= endInterval
        }
        
        let _ = (0...28).forEach{day in
            if let followerOfTheDay = counts?.filter({isValidDate(date: $0.createdAt!, day: day)}).last?.follower,
               let followerOfTheDayBefore = counts?.filter({isValidDate(date: $0.createdAt!, day: day + 1)}).last?.follower {
                let followerAdded = Int(followerOfTheDay - followerOfTheDayBefore)
                followers.append(followerAdded > 0 ? followerAdded : 1)
            } else  {
                followers.append(1)
            }
            
            if let tweetsOfTheDay = counts?.filter({isValidDate(date: $0.createdAt!, day: day)}).last?.tweets,
               let tweetsOfTheDayBefore = counts?.filter({isValidDate(date: $0.createdAt!, day: day + 1)}).last?.tweets {
                let tweetsAdded = Int(tweetsOfTheDay - tweetsOfTheDayBefore)
                tweets.append(tweetsAdded > 0 ? tweetsAdded : 1)
            } else {
                tweets.append(1)
            }
            
        }
        
        return (followers:followers, tweets: tweets)
        
    }
    
    static func cleanCountData(success: (() -> ())? = nil, before days: Double = 0) {
        
        let interval = Date().timeIntervalSince1970
        let intervalOfOneDay: Double = 60 * 60 * 24
        let intervalOfToday = Double(Int(interval) % Int(intervalOfOneDay))
        
        let daysNumber: Double = days
        let beginInterval: Date = Date().addingTimeInterval(-(intervalOfToday + daysNumber * intervalOfOneDay ))
        let endInterval: Date = beginInterval.addingTimeInterval(Double(intervalOfOneDay))
        
        let context = PersistenceContainer.shared.container.viewContext

        let oneDayIntervalPredicate: NSPredicate = NSPredicate(format: "(createdAt >= %@) && (createdAt <= %@)", beginInterval as CVarArg, endInterval as CVarArg)
        let countSortDescriptors = [NSSortDescriptor(keyPath: \Count.createdAt, ascending: true)]
        let fetchRequest: NSFetchRequest = Count.fetchRequest()
        fetchRequest.predicate = oneDayIntervalPredicate
        fetchRequest.sortDescriptors = countSortDescriptors
        
        do {
            let counts = try context.fetch(fetchRequest)
            
            counts.dropLast().forEach{context.delete($0)}
            
            try context.save()
            
            success?()
            
        } catch let error as NSError {
            print("count not fetched \(error), \(error.userInfo)")
        }
    }
}

