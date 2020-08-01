//
//  AuthView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/15.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import SwifteriOS
import UIKit
import SafariServices

struct AuthView: View {
    @EnvironmentObject var user: User
    
    var body: some View {
       Button(action: {self.login()}, label: {
                HStack {
                    Spacer()
                    Image("Logo")
                        .resizable()
                        .frame(width: 48, height: 48, alignment: .center)
                    Text("Press to Login")
                    Spacer()
                }

            })
       
    }
}

extension AuthView {
   
    func login() {
        let failureHandler: (Error) -> Void = { error in
            print(error.localizedDescription)
        }
        let url = URL(string: "fetchmee://success")!
        swifter.authorize(withCallback: url, presentingFrom:UIHostingController(rootView: self) , success: {token, _ in
            if let token = token {
                // 写入登陆后信息, writeInfo
                //把Token相关信息存储到文件中
                userDefault.set(token.key, forKey: "tokenKey")
                userDefault.set(token.secret, forKey: "tokenSecret")
                userDefault.set(token.userID, forKey: "userIDString")
                userDefault.set(token.screenName, forKey: "screenName")
                
                self.readInfo() //登录后读取信息并设置新的swifter
                
                userDefault.set(true, forKey: "isLoggedIn")
                self.user.isLoggedIn = true
                print(#line, "set isLoggedIn")
            }
        }, failure: failureHandler)
    }
   
//    func setForLogin() {
//        //设置未登录时候的界面状态
//    }
//    
//    
//    
//    func setForLogout() {
//        
//    }
    
    func readInfo() {
        //读取保存的auth信息并生成登录后的Swifter
        let tokenKey = userDefault.object(forKey: "tokenKey") as! String
        let tokenSecret = userDefault.object(forKey: "tokenSecret") as! String
        swifter = Swifter(consumerKey: "wa43gWPPaNLYiZCdvZLXlA",
                          consumerSecret: "BvKyqaWgze9BP3adOSTtsX6PnBOG5ubOwJmGpwh8w",
                          oauthToken: tokenKey,
                          oauthTokenSecret: tokenSecret)
        
        self.user.getMyInfo() //
    }
    

}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
