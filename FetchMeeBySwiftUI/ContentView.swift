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
//    @Environment(\.managedObjectContext) private var viewContext
//
    var body: some View {
        if self.loginUser.isLoggedIn {
            HubView()
//                .accentColor(self.loginUser.setting.themeColor.color)
        } else {
            AuthView()
//                .accentColor(self.loginUser.setting.themeColor.color)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
