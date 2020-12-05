//
//  TimelineProtocol.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/5.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation

protocol TimelineViewModel {
    var tweetIDStrings: [String] { get set}
    var isDone:Bool{ get set}
    var tweetIDStringOfRowToolsViewShowed: String? { get set}
}
