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

struct AlertOffAppCommand: AppCommand {

    func execute(in store: Store) {
        let delayOfDisappear = 5.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayOfDisappear, execute: {
            store.dipatch(.alertOff)
        })
    }
}
