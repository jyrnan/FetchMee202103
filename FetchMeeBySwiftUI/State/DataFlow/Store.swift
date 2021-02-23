//
//  Store.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/23.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import Combine

class Store: ObservableObject {
    @Published var appState = AppState()
    
    private var disposeBag = Set<AnyCancellable>()
    
    func dipatch(_ action: AppAction) {
        #if DEBUG
        print("[ACTION: \(action)")
        #endif
        
        let result = Store.reduce(state: appState, action: action)
        appState = result.0
        if let command = result.1 {
            #if DEBUG
            print("[COMMAND]: \(command)")
            #endif
            command.execute(in: self)
        }
    }
    
    static func reduce(state: AppState, action: AppAction) -> (AppState, AppCommand?) {
        var appState = state
        var appCommand: AppCommand?
        
        switch action {
        case .alertON(let text, let isWarning):
            appState.alerts.alertText = text
            appState.alerts.isWarning = isWarning
            appState.alerts.isPresentedAlert = true
            appCommand = AlertOffAppCommand()
            
        case .alertOff:
            appState.alerts.isPresentedAlert = false
        }
        return (appState, appCommand)
    }
}
