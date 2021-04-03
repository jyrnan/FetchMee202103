//
//  StatusCD+JSON_Save.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/13.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import CoreData
import Swifter

extension StatusCD {
    static func JSON_Save(from json: JSON,
                          isBookmarked: Bool? = nil,
                          isDraft: Bool = false) -> StatusCD {
        
        func stringToDate(from createdAt: String?) -> Date {
            guard let timeString = createdAt else {return Date()}
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            guard let date = timeFormat.date(from: timeString) else {return Date()}
        return date
    }
        
        let viewContext = PersistenceContainer.shared.container.viewContext
        let id = json["id_str"].string!
        var status: StatusCD
        
            
        let statusFetch: NSFetchRequest<StatusCD
        > = StatusCD
        .fetchRequest()
        statusFetch.predicate = NSPredicate(format: "%K = %@", #keyPath(StatusCD.id_str), id)
            
            
            if let result = try? viewContext.fetch(statusFetch).first {
                status = result
            } else {
                status = StatusCD(context: viewContext)
            }
        
        status.id_str = json["id_str"].string
        status.text = json["text"].string
        
        status.created_at = stringToDate(from: json["created_at"].string)
        
        let user = UserCD.updateOrSaveToCoreData(from: json["user"], isForBookmarkedUser: isBookmarked)
        
        status.user = user
        
        if let medias = json["extended_entities"]["media"].array{
            status.imageUrls = medias.map{$0["media_url_https"].string!}.joined(separator: " ")
        }
        
        
        if let isBookmarked = isBookmarked {
            status.isBookmarked = isBookmarked
        }
        status.isDraft = isDraft
        
        do {
            try viewContext.save()
        }catch {
            let nsError = error as NSError
            print(nsError.description)
        }
        
     return status
    }
    
    func getImageUrls() -> [String]? {
        guard let imageUrls = self.imageUrls else {return nil}
        return imageUrls.split(separator: " ").map{String($0)}
    }

}
