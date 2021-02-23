//
//  AuthViewController.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/19.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import Swifter
import SwiftUI

class AuthViewController: UIViewController, SFSafariViewControllerDelegate {
    
    var store: Store!
    
    var loginUser: User!
    
    @IBAction func login(_ sender: Any) {
        presentAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "\"FetchMee\" Wants to Use \"Twitter.com\" to Sign In",
                                      message: "This allows the app and website to share information about you", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: "Default action"), style: .default, handler: { _ in
            self.login()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func login() {
        let failureHandler: (Error) -> Void = { error in
            print(error.localizedDescription)
        }
        let url = URL(string: "fetchmee://success")!
        swifter.authorize(withCallback: url, presentingFrom:self, success: {token, response in
            if let token = token {
                print(#line, #function, response)
                
                // 写入登陆后信息, writeInfo
                //把Token相关信息存储到文件中
                userDefault.set(token.key, forKey: "tokenKey")
                userDefault.set(token.secret, forKey: "tokenSecret")
                userDefault.set(token.userID, forKey: "userIDString")
                userDefault.set(token.screenName, forKey: "screenName")
                
                userDefault.set(true, forKey: "isLoggedIn")
                self.loginUser.isLoggedIn = true
                
                let loginUser = UserInfo(id: token.userID!,
                                         screenName: token.screenName,
                                         tokenKey: token.key,
                                         tokenSecret: token.secret)
                self.store.appState.setting.loginUser = loginUser
                
                print(#line, "set isLoggedIn")
                print(#line, self.store.appState.setting.loginUser)
                
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
        
        self.loginUser.getUserInfo() 
    }
}


struct AuthViewFromVC: UIViewControllerRepresentable {
    
    @EnvironmentObject var store: Store
    
    var loginUser: User!
    
    func makeUIViewController(context: Context) -> AuthViewController {
        let authViewController = AuthViewController()
        authViewController.loginUser = loginUser
        authViewController.store = store
        return authViewController
    }
    
    func updateUIViewController(_ uiViewController: AuthViewController, context: Context) {
        print(#line)
    }
    
    
    typealias UIViewControllerType = AuthViewController
    
    
}
