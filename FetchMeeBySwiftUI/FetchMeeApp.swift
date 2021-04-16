//
//  FetchMeeApp.swift
//  FetchMee
//
//  Created by jyrnan on 2021/4/16.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData

@main
struct FetchMeeApp: App {
    var body: some Scene {
        MySecen()
    }
}

struct MySecen: Scene {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var store: Store = Store()
    
    var body: some Scene {
        WindowGroup {
            ContentView( )
                .environment(\.managedObjectContext, PersistenceContainer.shared.container.viewContext)
                .environmentObject(store)
        }
        .onChange(of: scenePhase, perform: {newScenePhase in
            if newScenePhase == .background {
                store.dipatch(.backgroundClear)
                }
            if newScenePhase == .active {
                if let loginUser = store.appState.setting.loginUser,
                   loginUser.tokenKey != nil {
                    store.dipatch(.userRequest(user: loginUser, isLoginUser: true))
                    store.dipatch(.fetchTimeline(timelineType: .mention, mode: .top))
//                    store.dipatch(.hubStatusRequest)
                }
                }
        })
    }
    
    
}
