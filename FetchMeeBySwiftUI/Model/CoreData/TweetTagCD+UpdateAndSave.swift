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
        
        let tagFetch: NSFetchRequest<TweetTagCD> = TweetTagCD.fetchRequest()
        tagFetch.predicate = NSPredicate(format: "%K = %@", #keyPath(TweetTagCD.text), text)
        var tag: TweetTagCD
        
        if let result = try? viewContext.fetch(tagFetch).first {
            tag = result
        } else {
            tag = TweetTagCD(context: viewContext)
        }
        
        tag.id = UUID()
        tag.createdAt = Date()
        tag.text = text
        tag.priority += Int16(priority)
        
        do {
            try viewContext.save()
        }catch {
            let nsError = error as NSError
            print(nsError.description)
        }
    }
    
    static func deleteUnusedTag() {
        let viewContext = PersistenceContainer.shared.container.viewContext
        
        let tagFetch: NSFetchRequest<TweetTagCD> = TweetTagCD.fetchRequest()
        
        if let result = try? viewContext.fetch(tagFetch) {
            result.filter{$0.priority == 0}.forEach{viewContext.delete($0)}
        }
        
        do {
            try viewContext.save()
        }catch {
            let nsError = error as NSError
            print(nsError.description)
        }
    }
}
