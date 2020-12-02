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
    @Published var users: [String: JSON] = [:]
    
    func addUser(userIDString: String, user: JSON) {
        self.users[userIDString] = user
    }
}
