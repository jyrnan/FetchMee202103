//
//  AppCommand_BGClear.swift
//  FetchMee
//
//  Created by jyrnan on 2021/4/14.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation

struct AppCommand_BGClearTask: AppCommand {
    func execute(in store: Store) {
        
        store.dipatch(.deselectTweetRow)
        store.dipatch(.clearTimelineData)
        
        UserCD.deleteNotFavoriteUser()
        TweetTagCD.deleteUnusedTag()
//        (0...28).reversed().forEach{Count.cleanCountData(before: Double($0))}
        Count.cleanCountData()
    }
}
