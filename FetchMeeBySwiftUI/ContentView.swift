//
//  ContentView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/21.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var user: User
    
    var body: some View {
        if self.user.isLoggedIn {
            TimelineView(user: self.user)
        } else {
            AuthView(user: self.user)
        }
}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(user: User())
    }
}
