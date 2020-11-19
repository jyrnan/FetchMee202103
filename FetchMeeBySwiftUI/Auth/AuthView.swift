//
//  AuthView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/15.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import UIKit
import SafariServices

struct AuthView: View {
    @EnvironmentObject var loginUser: User
    
    @State var isShowAuthView: Bool = false
    @State var isShowAlert: Bool = false

    let title = "\"FetchMee\" Wants to Use \"Twitter.com\" to Sign In"
    let message = "This allows the app and website to share information about you"

    var body: some View {
//        ZStack{
//       Button(action: {isShowAlert = true}, label: {
//                HStack {
//                    Spacer()
//                    Image("Logo")
//                        .resizable()
//                        .frame(width: 48, height: 48, alignment: .center)
//                    Text("Press to Login").foregroundColor(Color.init("TwitterBlue"))
//                    Spacer()
//                }
//
//            })
//       .alert(isPresented: $isShowAlert) {Alert(title: Text(title), message: Text(message), primaryButton: .default(Text("Continue"), action: {self.isShowAuthView = true}), secondaryButton: .cancel())}
//       if isShowAuthView {
        authViewFromVC(loginUser: loginUser).ignoresSafeArea()
        
//    }
//    }
    }
}

extension AuthView {
   
    func login() {
        let failureHandler: (Error) -> Void = { error in
            print(error.localizedDescription)
        }
        let url = URL(string: "fetchmee://success")!
        swifter.authorize(withCallback: url, presentingFrom:UIHostingController(rootView: self) ,  success: {token, _ in
            if let token = token {
                // 写入登陆后信息, writeInfo
                //把Token相关信息存储到文件中
                userDefault.set(token.key, forKey: "tokenKey")
                userDefault.set(token.secret, forKey: "tokenSecret")
                userDefault.set(token.userID, forKey: "userIDString")
                userDefault.set(token.screenName, forKey: "screenName")
                
                userDefault.set(true, forKey: "isLoggedIn")
                self.loginUser.isLoggedIn = true
                print(#line, "set isLoggedIn")
                
                self.readInfo() //登录后读取信息并设置新的swifter
            }
        }, failure: failureHandler)
    }
   
    
    func readInfo() {
        //读取保存的auth信息并生成登录后的Swifter
        let tokenKey = userDefault.object(forKey: "tokenKey") as! String
        let tokenSecret = userDefault.object(forKey: "tokenSecret") as! String
        swifter = Swifter(consumerKey: "wa43gWPPaNLYiZCdvZLXlA",
                          consumerSecret: "BvKyqaWgze9BP3adOSTtsX6PnBOG5ubOwJmGpwh8w",
                          oauthToken: tokenKey,
                          oauthTokenSecret: tokenSecret)
        
        self.loginUser.getUserInfo() //
    }
    

}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}

class SafariDelegate: NSObject, SFSafariViewControllerDelegate {
    
    
}
