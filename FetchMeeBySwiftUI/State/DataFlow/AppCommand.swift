//
//  AppCommand.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/23.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Combine

protocol AppCommand {
    func execute(in store: Store)
}
