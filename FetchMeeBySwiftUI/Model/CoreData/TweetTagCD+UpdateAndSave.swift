//
//  TweetTagCD.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/7.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import CoreData

extension TweetTagCD {
    static func saveTag(text: String, priority: Int, to viewContext: NSManagedObjectContext = PersistenceContainer.shared.container.viewContext) {
        
        let tag = TweetTagCD()
        tag.text = text
        tag.priority += Int16(priority)
        
        do {
            try viewContext.save()
        }catch {
            let nsError = error as NSError
            print(nsError.description)
        }
    }
}
