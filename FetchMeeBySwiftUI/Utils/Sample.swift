//
//  Sample.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2021/7/14.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Swifter

#if DEBUG

extension Store {
    static var sample: Store {
        let s = Store()
        s.appState.setting.loginUser = User.SampleOfLogin
        s.appState.timelineData.timelines["Home"]?.newTweetNumber = 12
        s.appState.timelineData.timelines["Home"]?.tweetIDStrings = (1...10).map{String($0)}
        s.appState.timelineData.timelines["Session"] = AppState.TimelineData.Timeline.sampleOfSession
        s.appState.timelineData.timelines["Mention"]?.newTweetNumber = 5
        return s
    }
}

extension AppState.TimelineData.Timeline {
    static var sampleOfSession: AppState.TimelineData.Timeline {
        var timeline = AppState.TimelineData.Timeline()
        timeline.tweetIDStrings = (1...3).map{String($0)}
        timeline.status = (1...3).map{_ in Status.sample}
        return timeline
    }
}

extension Status {
    static var sample: Status {
        let status = Status(user: User.SampleOfNomal,
                            text: "人体对其所摄入的葡萄糖的处置调控能力称为「葡萄糖耐量」。正常人的糖调节机制完好，无论进食多少，血糖都能保持在一个比较稳定的范围内，即使一次性摄入大量的糖分",
                            attributedString: JSON(dictionaryLiteral: ("text", "@人体 @对其所摄入 的葡萄糖的处置调控能力称为「葡萄糖耐量」。正常人的糖调节机制完好，无论进食多少，血糖都能保持在一个比较稳定的范围内，即使一次性摄入大量的糖分"))
                                .getAttributedString(),
                            imageUrls: ["", "", "", ""])
        return status
    }
}

extension User {
    static var SampleOfLogin: User {
        var user = User()
        user.id = "loginUser"
        return user
    }
    
    static var SampleOfNomal: User {
        var user = User()
        user.id = "nomalUser"
        return user
    }
}


#endif
