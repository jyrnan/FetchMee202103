//
//  Persistance.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/6.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData

struct PersistenceContainer {
    ///用来存储最新删除时间的key值
    private static let lastDeletedKey = "lastDeleted"
    
    static let shared = PersistenceContainer()
    
    var container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "FetchMee")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                print(error.description)
//                fatalError("Unresoved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    //MARK:- 自定义的CoreData相关数据保存时间方法
    static func setLastDeleted(date: Date = Date()) {
            UserDefaults.standard.set(date, forKey: PersistenceContainer.lastDeletedKey)
        
    }
    
    static func getLastDeleted() -> Date? {
        
            return UserDefaults.standard.object(forKey: PersistenceContainer.lastDeletedKey) as? Date
       
    }
    
    static func updateLastDeleted() {
        var lastDeleted = self.getLastDeleted()
        lastDeleted = lastDeleted?.addingTimeInterval(36)
        self.setLastDeleted(date: lastDeleted ?? Date())
    }
    
}

extension PersistenceContainer {
    
}
