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
    
    let adapter = Adapter()
    
    var statuses: [String: Status] = [:]
    var users: [String: User] = [:]
    
    var bookmarkedStatusCD: [StatusCD] {
        let viewContext = PersistenceContainer.shared.container.viewContext
        let statusSortDescriptors = [NSSortDescriptor(keyPath: \StatusCD.created_at, ascending: false)]
        let bookmarkedStatusPredicate = NSPredicate(format: "%K == %d", #keyPath(StatusCD.isBookmarked), true)
        
        let bookmarkedStatusRequest:NSFetchRequest<StatusCD> = NSFetchRequest(entityName: "StatusCD")
        bookmarkedStatusRequest.sortDescriptors = statusSortDescriptors
        bookmarkedStatusRequest.predicate = bookmarkedStatusPredicate
        
        guard let bookmarkedStatuses = try? viewContext.fetch(bookmarkedStatusRequest) else {return []}
        return bookmarkedStatuses
    }
    
    var bookMarkedUserCD: [UserCD] {
        let viewContext = PersistenceContainer.shared.container.viewContext
        let UserSortDescriptors = [NSSortDescriptor(keyPath: \UserCD.createdAt, ascending: false)]
        let bookmarkedUserPredicate = NSPredicate(format: "%K == %d", #keyPath(UserCD.isBookmarkedUser), true)
        
        let bookmarkedUserRequest:NSFetchRequest<UserCD> = NSFetchRequest(entityName: "UserCD")
        bookmarkedUserRequest.sortDescriptors = UserSortDescriptors
        bookmarkedUserRequest.predicate = bookmarkedUserPredicate
        
        guard let bookmarkedUseres = try? viewContext.fetch(bookmarkedUserRequest) else {return []}
        return bookmarkedUseres
    }
    
    
    func addStatus(data: JSON) {
        if let id = data["id_str"].string {
            statuses[id] = adapter.convertToStatus(from: data)
        }
    }
    
    /// 将获取的用户数据保存到CoreData中，并在保存完成后，转换成user格式
    /// - Parameters:
    ///   - data: 传入的用户数据
    ///   - isLoginUser: 标记是否是登陆用户
    ///   - token: 登陆用户的token信息
    /// - Returns: User格式的用户
    func addUser(data: JSON,
                 isLoginUser: Bool? = nil,
                 token: (String?, String?)? = nil,
                 isFavoriteUser: Bool? = nil) -> User {
        guard let id = data["id_str"].string else {return User()}
        //TODO：更新最新的用户follow和推文数量信息
        //利用数据来更新userCD
        let userCD = UserCD.updateOrSaveToCoreData(from: data,
                                                   dataHandler: adapter.updateUserCD(_:with:),
                                                   isLoginUser: isLoginUser,
                                                   token: token,
                                                   isFavoriteUser: isFavoriteUser)
        let user = userCD.convertToUser()
        users[id] = user
        return user
        
    }
    
    //MARK: -
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
        
        if let userCD = bookMarkedUserCD.filter({$0.userIDString == id}).first {
            let user = userCD.convertToUser()
            users[id] = user
            return user
        }
        
        return User()
    }
}


