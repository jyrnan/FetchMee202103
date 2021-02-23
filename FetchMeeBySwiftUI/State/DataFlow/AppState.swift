//
//  AppState.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/23.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Combine

struct AppState {
    var alerts = MyAlert()
}

extension AppState {
    struct Alert: Identifiable {
        var id = UUID()
        var isPresentedAlert: Bool = false
        var alertText: String = ""
        var isWarning: Bool = false
    }
}
