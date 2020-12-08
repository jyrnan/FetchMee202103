//
//  StatusRepository.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/2.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import Swifter

class StatusRepository: ObservableObject {
    static var shared = StatusRepository()
    private init() {}
    
    @Published var status: [String: JSON] = [:] {
        willSet {
//            print(#line, #function, newValue)
        }
    }
    
    func addStatus(_ status: JSON) {
        if let id = status["id_str"].string {
            self.status[id] = status
            print(#line, #file, "status added, \(self.status.count) status total")
        }
    }
}

