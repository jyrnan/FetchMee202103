//
//  AppError.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/23.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation

enum AppError: Error, Identifiable {
    var id: String {localizedDescription}
    
    case netwokingFailed(Error)
}

extension AppError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .netwokingFailed(let error):
            return error.localizedDescription
        }
    }
}
