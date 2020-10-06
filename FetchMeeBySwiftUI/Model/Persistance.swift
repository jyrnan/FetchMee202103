//
//  Persistance.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/6.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData

//struct PersistenceContainer {
//    static let shared = PersistenceContainer()
//    
//    var container: NSPersistentCloudKitContainer
//    
//    init(inMemory: Bool = false) {
//        container = NSPersistentCloudKitContainer(name: "FetchMee")
//        if inMemory {
//            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
//        }
//        container.loadPersistentStores(completionHandler: {
//            (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresoved error \(error), \(error.userInfo)")
//            }
//        })
//        
//        container.viewContext.automaticallyMergesChangesFromParent = true
//    }
//    
//}
