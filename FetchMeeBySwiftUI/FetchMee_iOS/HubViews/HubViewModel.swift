//
//  HubViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/23.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation

class HubViewModel: ObservableObject {
    var mention: Timeline
    
    init(mention: Timeline) {
        self.mention = mention
    }
}
