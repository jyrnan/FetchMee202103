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
    static func JSON_Save(from json: JSON) -> Status_CD {
        
        func stringToDate(from createdAt: String?) -> Date {
            guard let timeString = createdAt else {return Date()}
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            guard let date = timeFormat.date(from: timeString) else {return Date()}
        return date
    }
        
        let viewContext = PersistenceContainer.shared.container.viewContext
        let id = json["id_str"].string!
        var status: Status_CD
            
        let statusFetch: NSFetchRequest<Status_CD> = Status_CD.fetchRequest()
        statusFetch.predicate = NSPredicate(format: "%K = %@", #keyPath(Status_CD.id_str), id)
            
            
            if let result = try? viewContext.fetch(statusFetch).first {
                status = result
            } else {
                status = Status_CD(context: viewContext)
            }
        
        status.id_str = json["id_str"].string
        status.text = json["text"].string
        
        status.created_at = stringToDate(from: json["created_at"].string)
        
        let user = TwitterUser.updateOrSaveToCoreData(from: json["user"])
        
        status.user = user
        
//        if let medias = json["extended_entities"]["media"].array{
//            status.imageUrls = medias.map{$0["media_url_https"].string!
//            }
//        }
        do {
            try viewContext.save()
        }catch {
            let nsError = error as NSError
            print(nsError.description)
        }
        
     return status
    }
    
    

}
