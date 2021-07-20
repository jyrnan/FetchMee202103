//
//  AppCommand_addUesrCDToStore.swift
//  AppCommand_addUesrCDToStore
//
//  Created by jyrnan on 2021/7/19.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import CoreData

struct AppCommand_addUserCDToStore: AppCommand {
    
    func execute(in store: Store) {
        var users: [String: User] = store.appState.timelineData.users
        
        let viewContext = PersistenceContainer.shared.container.viewContext
        let UserSortDescriptors = [NSSortDescriptor(keyPath: \UserCD.createdAt, ascending: false)]
//        let bookmarkedUserPredicate = NSPredicate(format: "%K == %d", #keyPath(UserCD.isBookmarkedUser), true)
        
        let bookmarkedUserRequest:NSFetchRequest<UserCD> = NSFetchRequest(entityName: "UserCD")
        bookmarkedUserRequest.sortDescriptors = UserSortDescriptors
//        bookmarkedUserRequest.predicate = bookmarkedUserPredicate
        
        guard let bookmarkedUseres = try? viewContext.fetch(bookmarkedUserRequest) else {return}
        
        bookmarkedUseres.forEach{
            let user = $0.convertToUser()
            users[user.idString] = user
        }
        
        store.dispatch(.updateUsers(users: users))
    }
    
    
}
