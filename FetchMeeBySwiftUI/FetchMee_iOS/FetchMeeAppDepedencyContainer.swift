//
//  FetchMeeAppDepedencyContainer.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/30.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation

class FetchMeeAppDependencyContainer {
    // MARK: - Properties
    let sharedStatusRepository: StatusRepository
    let sharedUserRepository: UserRepository
    let contentViewModel: ContentViewModel
    
    // MARK: - Methods
    
    public init() {
        
        func makeContentViewModel() -> ContentViewModel {
            return ContentViewModel()}
        
        self.sharedStatusRepository = StatusRepository.shared
        self.sharedUserRepository = UserRepository.shared
        
        self.contentViewModel = makeContentViewModel()
        
    }
    
    func makeHubViewModel() -> HubViewModel {
        let dependancyContainer = FetchMeeHubDependencyContainer(appDependencyContainer: self)
        return dependancyContainer.makeHubViewModel()
    }
}
