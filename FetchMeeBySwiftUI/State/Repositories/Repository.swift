//
//  Repository.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/17.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Swifter
import CoreData

class Repository  {
 
    weak var store: Store?
    let adapter = Adapter()
    
    var statuses: [String: Status] = [:]
    var users: [String: User] = [:]
    
    var bookmarkedStatusCD: [StatusCD] {
        guard let viewContext = store?.context else {return []}
        let statusSortDescriptors = [NSSortDescriptor(keyPath: \StatusCD.created_at, ascending: false)]
        let bookmarkedStatusPredicate = NSPredicate(format: "%K == %d", #keyPath(StatusCD.isBookmarked), true)
        
        let bookmarkedStatusRequest:NSFetchRequest<StatusCD> = NSFetchRequest(entityName: "StatusCD")
        bookmarkedStatusRequest.sortDescriptors = statusSortDescriptors
        bookmarkedStatusRequest.predicate = bookmarkedStatusPredicate
        
        guard let bookmarkedStatuses = try? viewContext.fetch(bookmarkedStatusRequest) else {return []}
        return bookmarkedStatuses
    }
    
    func addStatus(data: JSON) {
        if let id = data["id_str"].string {
          statuses[id] = adapter.convertToStatus(from: data)
        }
    }
    
    func addUser(data: JSON, isLoginUser: Bool? = nil) {
        guard let id = data["id_str"].string else {return}
        
        //利用数据来更新userCD
        let userCD = UserCD.updateOrSaveToCoreData(from: data,
                                                   dataHandler: adapter.updateUserCD(_:with:),
                                           isLoginUser: isLoginUser)
//        //从userCD转换成user
//        let user = adapter.convertUserCDToUser(userCD: userCD)
        
        users[id] = userCD.convertToUser()
    }
    
    func getStatus(byID id: String) -> Status {
        if let status = self.statuses[id] {
            return status
        }
        return Status()
    }
    
    func getUser(byID id: String) -> User {
        if let user = self.users[id] {
            return user
        }
        return User()
    }
}


