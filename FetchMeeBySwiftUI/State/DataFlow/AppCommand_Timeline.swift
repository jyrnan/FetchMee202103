//
//  AppCommand_Timeline.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/24.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation

struct TimelineCommand: AppCommand {
    
    enum UpdateMode {
        case top
        case bottom
    }
    
    var timeline: [String]
    var updateMode: UpdateMode
    
    func execute(in store: Store) {
        let swifter = store.swifter
        
    }
    
}
