//
//  SceneDelegate.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import UIKit
import SwiftUI
import SwifteriOS
import SafariServices
import Combine

var swifter: Swifter = Swifter(consumerKey: "wa43gWPPaNLYiZCdvZLXlA",
                               consumerSecret: "BvKyqaWgze9BP3adOSTtsX6PnBOG5ubOwJmGpwh8w")


let userDefault = UserDefaults.init()
let cfh = CacheFileHandler() //设置下载文件的缓存位置
let session = URLSession.shared
//var themeColor: Color = Color.pink

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var loginUser: User = User() //App登录使用的用户
    var alerts: Alerts = Alerts()
    var downloader = Downloader(configuation: URLSessionConfiguration.default)


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        self.loginUser.isLoggedIn = userDefault.object(forKey: "isLoggedIn") as? Bool ?? false
        self.loginUser.myInfo.setting.load() //读取存储多设置
        let contentView = ContentView()
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            if self.loginUser.isLoggedIn {
                // 读取token信息
                let tokenKey = userDefault.object(forKey: "tokenKey") as! String
                let tokenSecret = userDefault.object(forKey: "tokenSecret") as! String
                //设置登录后的Swifter以及获取loginUser的信息
                swifter = Swifter(consumerKey: "wa43gWPPaNLYiZCdvZLXlA",
                                  consumerSecret: "BvKyqaWgze9BP3adOSTtsX6PnBOG5ubOwJmGpwh8w",
                                  oauthToken: tokenKey,
                                  oauthTokenSecret: tokenSecret)
                
                self.loginUser.getMyInfo()}

                window.rootViewController = UIHostingController(rootView: contentView
                                                                    .environmentObject(alerts).environmentObject(loginUser)
                                                                    .accentColor(self.loginUser.myInfo.setting.themeColor.color).environmentObject(downloader)
                                                                    )
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


extension SceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let context = URLContexts.first else { return }
        let callbackUrl = URL(string: "fetchmee://")!
        Swifter.handleOpenURL(context.url, callbackURL: callbackUrl)
    }
}

struct SceneDelegate_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
