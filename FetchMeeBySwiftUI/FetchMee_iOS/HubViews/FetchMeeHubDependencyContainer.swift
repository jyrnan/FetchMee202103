//
//  FetchMeeHubDependencyContainer.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/6.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation

public class FetchMeeHubDependencyContainer {
    let sharedStatusRepository: StatusRepository
    let sharedUserRepository: UserRepository
    init(appDependencyContainer: FetchMeeAppDependencyContainer) {
        self.sharedStatusRepository = appDependencyContainer.sharedStatusRepository
        self.sharedUserRepository = appDependencyContainer.sharedUserRepository
    }
    
    func makeHubViewModel() -> HubViewModel {
        let mention = makeMentionTimeline()
        return HubViewModel(mention: mention)
    }
    
    func makeMentionTimeline() -> Timeline {
        return Timeline(type: .mention)
    }
}
