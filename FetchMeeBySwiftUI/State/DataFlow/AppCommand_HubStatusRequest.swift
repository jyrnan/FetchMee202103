//
//  AppCommand_CoreData.swift
//  FetchMee
//
//  Created by jyrnan on 2021/4/1.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

struct AppCommand_HubStatusRequest: AppCommand {
    
    func execute(in store: Store) {
        var hubStatus: AppState.TimelineData.HubStatus = (nil, nil, nil)
        guard let viewContext = store.context else {return}
        
        //设置排序和筛选选项
        let statusSortDescriptors = [NSSortDescriptor(keyPath: \StatusCD.created_at, ascending: false)]
        let draftsSortDescriptors = [NSSortDescriptor(keyPath: \TweetDraft.createdAt, ascending: false)]
        let myStatusPredicate = NSPredicate(format: "%K == %@", #keyPath(StatusCD.user.userIDString), store.appState.setting.loginUser?.id ?? "0000")
        let bookmarkedStatusPredicate = NSPredicate(format: "%K == %d", #keyPath(StatusCD.isBookmarked), true)
        
        let myStatusRequest:NSFetchRequest<StatusCD> = NSFetchRequest(entityName: "StatusCD")
        myStatusRequest.sortDescriptors = statusSortDescriptors
        myStatusRequest.predicate = myStatusPredicate
        if let myStatuses = try? viewContext.fetch(myStatusRequest) {
            hubStatus.myLatestStatus = myStatuses.first
        }
        
        let bookmarkedStatusRequest:NSFetchRequest<StatusCD> = NSFetchRequest(entityName: "StatusCD")
        bookmarkedStatusRequest.sortDescriptors = statusSortDescriptors
        bookmarkedStatusRequest.predicate = bookmarkedStatusPredicate
        if let bookmarkedStatuses = try? viewContext.fetch(bookmarkedStatusRequest) {
            hubStatus.bookmarkedStatus = bookmarkedStatuses.first
        }
        
        let myDraftsRequest: NSFetchRequest<TweetDraft> = NSFetchRequest(entityName: "TweetDraft")
        myDraftsRequest.sortDescriptors = draftsSortDescriptors
        if let myDrafts = try? viewContext.fetch(myDraftsRequest) {
            hubStatus.myLatestDraft = myDrafts.first
        }
        
        store.dipatch(.updateHubStatus(hubStatus: hubStatus))
}
}
