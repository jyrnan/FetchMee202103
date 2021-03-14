//
//  CreatedTimeView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/16.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct CreatedTimeView: View {
    var createdTime: String?
    var created_at: Date?
    
    @State var updatedTime: String = ""
    var body: some View {
        Text(updatedTime)
            .font(.subheadline)
            .foregroundColor(.gray)
            .lineLimit(1)
            .onAppear {
                if createdTime != nil {
                updatedTime = self.updateTime(createdTime: createdTime)
                } else {
                    updatedTime = self.updateTime(created_at: created_at)
                }
            }
    }
}

extension CreatedTimeView {
    func updateTime(createdTime: String?) -> String {
        guard createdTime != nil else {
            return "N/A"
        }
        var result : String = "N/A"
        let timeString = createdTime!
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        if let date = timeFormat.date(from: timeString) {
            let df = DateFormatter()
            df.dateStyle = .short
            df.timeStyle = .none
           
            let sinceNow = -Int((date.timeIntervalSinceNow))
            //判断时间显示的格式，
            switch sinceNow {
            case 0..<60: result = "· " + String(sinceNow) + "s"
            case 60..<3600: result = "· " + String(sinceNow / 60) + "m"
            case 3600..<(3600 * 24): result = "· " + String(sinceNow / 3600) + "h"
            case (3600 * 24)..<(3600 * 24 * 3): result = "· " + String(sinceNow / 86400) + "d"
            default: result = "· " + df.string(from: date)
            }
    }
        return result
}
    func updateTime(created_at: Date?) -> String {
        guard created_at != nil else {
            return "N/A"
        }
        var result : String = "N/A"
//        let timeString = createdTime!
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        if let date = created_at {
            let df = DateFormatter()
            df.dateStyle = .short
            df.timeStyle = .none
           
            let sinceNow = -Int((date.timeIntervalSinceNow))
            //判断时间显示的格式，
            switch sinceNow {
            case 0..<60: result = "· " + String(sinceNow) + "s"
            case 60..<3600: result = "· " + String(sinceNow / 60) + "m"
            case 3600..<(3600 * 24): result = "· " + String(sinceNow / 3600) + "h"
            case (3600 * 24)..<(3600 * 24 * 3): result = "· " + String(sinceNow / 86400) + "d"
            default: result = "· " + df.string(from: date)
            }
    }
        return result
}
}

struct CreatedTimeView_Previews: PreviewProvider {
    static var previews: some View {
        CreatedTimeView(createdTime: "Mon Dec 08 15:37:22 +0000 2008")
    }
}
