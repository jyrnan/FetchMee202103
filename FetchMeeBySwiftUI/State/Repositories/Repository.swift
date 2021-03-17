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
    
    static var shared = Repository()
    private init() {}
    
    var status: [String: JSON] = [:]
    var users: [String: JSON] = [:]
    
    func addStatus(data: JSON) {
        if let id = data["id_str"].string {
            status[id] = data
        }
    }
    
    func addUser(data: JSON) {
        if let id = data["id_str"].string {
            users[id] = data
        }
    }
}
