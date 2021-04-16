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
    var loginUser: User? {store.appState.setting.loginUser}
    
    var isLoggedIn:Bool {store.appState.setting.loginUser != nil}

    var body: some View {
        if isLoggedIn {
            HubView()
                .accentColor(store.appState.setting.userSetting?.themeColor.color)
        } else {
            
                AuthView().ignoresSafeArea()
                .accentColor(store.appState.setting.userSetting?.themeColor.color)
                
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Store())
    }
}
