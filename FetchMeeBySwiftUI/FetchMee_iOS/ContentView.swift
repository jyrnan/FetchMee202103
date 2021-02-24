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
    
    @ObservedObject var viewModel: ContentViewModel
    
    @EnvironmentObject var store: Store
    var loginUser: UserInfo {store.appState.setting.loginUser ?? UserInfo()}
    
    var isLoggedIn:Bool {store.appState.setting.loginUser != nil}

    var body: some View {
        if isLoggedIn {
            HubView()
                .accentColor(loginUser.setting.themeColor.color)
        } else {
            AuthViewFromVC().ignoresSafeArea()
                .accentColor(loginUser.setting.themeColor.color)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel())
    }
}
