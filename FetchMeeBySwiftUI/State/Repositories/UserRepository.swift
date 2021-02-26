//
//  UserRepository.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/2.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import Swifter

class UserRepository: ObservableObject {
    
    static var shared = UserRepository()
    private init() {}
    
    @Published var users: [String: JSON] = [:]
    
    func addUser(_ user: JSON) {
        if let id = user["id_str"].string {
            self.users[id] = user
        }
    }
}
