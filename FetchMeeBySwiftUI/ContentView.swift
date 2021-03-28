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
    var loginUser: UserInfo? {store.appState.setting.loginUser}
    
    var isLoggedIn:Bool {store.appState.setting.loginUser != nil}

    var body: some View {
        if isLoggedIn {
            HubView()
                .accentColor(loginUser?.setting.themeColor.color)
        } else {
            ZStack{
                
            AuthViewFromVC().ignoresSafeArea()
                .accentColor(loginUser?.setting.themeColor.color)
                Text("Not sign in now")
                    .foregroundColor(.gray)
                    .onTapGesture {
                        store.dipatch(.updateLoginAccount(loginUser: UserInfo(name: "FetchMee", screenName: "FetcheMeeApp")))
                        //新建非登录的本地用户
                        TwitterUser.updateOrSaveToCoreData(from: nil)
                    }
                    .frame(width: 200, height: 400, alignment: .bottom)
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Store())
    }
}
