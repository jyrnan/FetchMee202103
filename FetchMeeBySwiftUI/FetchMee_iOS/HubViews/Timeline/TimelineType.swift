//
//  TimelineType.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/2.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import SwiftUI
import Swifter

enum TimelineType: Equatable {
    case home
    case mention
    case list(id: String, listName: String)
    case user(userID:String)
    case session
    case message
    case favorite
    
    struct UIData {
        let iconImageName : String
        let themeColor: Color
    }
    
    var rawValue: String {
        switch self {
        case .home: return "Home"
        case .mention: return "Mention"
        case .favorite: return "Favaorite"
        case .list(let _, let name): return name
        default: return "Default"
        }
    }
    
    var uiData: UIData {
        switch self {
        case .home:
            return UIData(iconImageName: "house.circle", themeColor: Color.init("TwitterBlue"))
        case .mention:
            return UIData(iconImageName: "at.circle", themeColor: Color.init("DarkOrange"))
        case .message:
            return UIData(iconImageName: "envelope.circle", themeColor: .orange)
        case .list:
            return UIData(iconImageName: "list.bullet", themeColor: Color.init("DarkGreen"))
        case .favorite:
            return UIData(iconImageName: "heart.circle", themeColor: Color.pink)
        default:
            return UIData(iconImageName: "list.bullet", themeColor: Color.init("TwitterBlue"))
        }
    }
}
