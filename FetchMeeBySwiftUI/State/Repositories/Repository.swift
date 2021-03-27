//
//  Repository.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/17.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Swifter

class Repository  {
 
    weak var store: Store?
    let adapter = JSONAdapter()
    
    var statuses: [String: Status] = [:]
    var users: [String: UserInfo] = [:]
    
    func addStatus(data: JSON) {
        if let id = data["id_str"].string {
          statuses[id] = adapter.convertToStatus(from: data)
        }
    }
    
    func addUser(data: JSON) {
        guard let id = data["id_str"].string else {return}
        var user = users[id] ?? UserInfo()
            adapter.convertAndUpdateUser(update: &user, with: data)
            users[id] = user
    }
    
    func getStatus(byID id: String) -> Status {
        if let status = self.statuses[id] {
            return status
        }
//        store?.dipatch(.tweetOperation(operation: .fetchTweet(id: id)))
        return Status()
    }
}


