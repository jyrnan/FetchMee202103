//
//  Status_CD+JSON_Save.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/13.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import CoreData
import Swifter

extension Status_CD {
    static func JSON_Save(from status: JSON) {
        let viewContext = PersistenceContainer.shared.container.viewContext
        let id = status["id_str"].string!
        var status: Status_CD
            
        let statusFetch: NSFetchRequest<Status_CD> = Status_CD.fetchRequest()
        statusFetch.predicate = NSPredicate(format: "%K = %@", #keyPath(Status_CD.id_str), id)
            
            
            if let result = try? viewContext.fetch(statusFetch).first {
                status = result
            } else {
                status = Status_CD(context: viewContext)
            }
        
        
    }
}
