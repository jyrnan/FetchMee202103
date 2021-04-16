//
//  AuthView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/15.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import AuthenticationServices


struct AuthView: View {
    @EnvironmentObject var store: Store
    var body: some View {
        VStack {
            Image( "Logo")
                .resizable()
                .frame(width: 96, height: 96, alignment: .center)
            
            Text("FetchMee needs permission to access your account")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
                .padding(.vertical, 30)
            
            Button(
                action: {
                    self.store.dipatch(.login(loginUser: nil))
                },
                label: {
                    Text(" Sign in with Twitter ")
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Capsule())
                })
            
            Button(
                action: {
                    store.dipatch(.updateLoginAccount(loginUser: User(name: "FetchMee", screenName: "FetcheMeeApp")))
                    //新建非登录的本地用户
                    UserCD.updateOrSaveToCoreData(from: nil)
                },
                label: {
                    Text("Not sign in now")
                        .foregroundColor(.gray)
                        .padding()
                })
            
        }
    }
}


struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}

