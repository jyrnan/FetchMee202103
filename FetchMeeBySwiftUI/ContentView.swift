//
//  ContentView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/21.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

struct ContentView: View {
    
    @EnvironmentObject var store: Store
    
    var isLoggedIn:Bool
//    {store.appState.setting.loginUser != nil}
    
    var body: some View {
        if isLoggedIn {
            HubView(tweetText: $store.appState.setting.tweetInput.tweetText)
                .accentColor(store.appState.setting.userSetting?.themeColor.color)
        } else {
            
            AuthView()
                .ignoresSafeArea()
                .accentColor(store.appState.setting.userSetting?.themeColor.color)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let store = Store()
    static var previews: some View {
        ContentView(isLoggedIn: false)
            .environmentObject(store)
    }
}
