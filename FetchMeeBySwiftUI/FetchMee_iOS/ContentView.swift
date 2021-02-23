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
    @EnvironmentObject var loginUser: User
    @ObservedObject var viewModel: ContentViewModel
    
    @EnvironmentObject var store: Store
    
    var isLoggedIn:Bool {store.appState.setting.loginUser != nil}

    var body: some View {
        if isLoggedIn {
            HubView()
                .accentColor(self.loginUser.setting.themeColor.color)
        } else {
            AuthViewFromVC(loginUser: loginUser).ignoresSafeArea()
                .accentColor(self.loginUser.setting.themeColor.color)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel())
    }
}
