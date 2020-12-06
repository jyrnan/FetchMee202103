//
//  TimelineType.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/2.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import SwiftUI

enum TimelineType: String {
    case home = "Home"
    case mention = "Mention"
    case list = "List"
    case user
    case session
    case message = "Message"
    case favorite = "Favorite"
    
    struct UIData {
        let iconImageName : String
        let themeColor: Color
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
