//
//  SceneDelegate.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import UIKit
import SwiftUI
import Swifter
import SafariServices
import Combine
import CoreData
import BackgroundTasks

//TODO: 取消这个swifter的全局变量？
var swifter: Swifter = Swifter(consumerKey: "wa43gWPPaNLYiZCdvZLXlA",
                               consumerSecret: "BvKyqaWgze9BP3adOSTtsX6PnBOG5ubOwJmGpwh8w")


let userDefault = UserDefaults.init()
let cfh = CacheFileHandler() //设置下载文件的缓存位置
let session = URLSession.shared

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    ///注册一个后台执行刷新的任务
    var bgFetchTask: (@escaping () -> ()) -> () = {completeHandler in completeHandler()}
    
//    var loingUser: User = User() //App登录使用的用户
    var alerts: Alerts = Alerts()
    var downloader = Downloader(configuation: URLSessionConfiguration.default)
    
    var store: Store = Store()
    
    let context = PersistenceContainer.shared.container.viewContext
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // Create the SwiftUI view that provides the window contents.

        let contentView = ContentView()
        
        store.context = context
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            if let loginUser = store.appState.setting.loginUser {

                swifter = store.swifter //临时保证全局变量还能使用

                store.dipatch(.userRequest(user: loginUser))
            }
            
            window.rootViewController = UIHostingController(
                rootView: contentView
                    .environmentObject(alerts)
                    .environmentObject(store)
                    .environment(\.managedObjectContext, context))
            
            self.window = window
            window.makeKeyAndVisible()
        }
        
        // MARK: Registering Launch Handlers for Tasks
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jyrnan.FetchMee.post", using: nil) { task in
            //后台发推操作
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jyrnan.FetchMee.process", using: nil) {task in
            //Process后台发推操作
            self.handleProcess(task: task as! BGProcessingTask)
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
        
        //保存用户设置
//        loingUser.setting.save()
        
        //加入定时程序
        scheduledRefresh()
        scheduledProcess()
        
        if let loginUser = store.appState.setting.loginUser { store.dipatch(.userRequest(user: loginUser))
        }
       
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

extension SceneDelegate {
    
    var timeStamp: String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .long
        formatter.timeZone = .current
        let timeStamp = formatter.string(from: now)
        return timeStamp
    }
    
    
    // MARK: - Scheduling Tasks
    
    
    func scheduledRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.jyrnan.FetchMee.post")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 5)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            
            let taskSetText = "BGAPPRefreshTaskRequest set."
            self.alerts.setLogMessage(text: "\(self.timeStamp) \(taskSetText)")
            
            
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    func scheduledProcess() {
        let request = BGProcessingTaskRequest(identifier: "com.jyrnan.FetchMee.process")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 10)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            
            let taskSetText = "BGAProcessingTaskRequest set."
            self.alerts.setLogMessage(text: "\(self.timeStamp) \(taskSetText)")
            
            
        } catch {
            print("Could not schedule database cleaning: \(error)")
        }
    }
    
    // MARK: - Handling Launch for Tasks
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduledRefresh()
        
        task.expirationHandler = {
            let expirationText = "BGAPPRefreshTask unexpectedly exit."
            
            self.alerts.setLogMessage(text: "\(self.timeStamp) \(expirationText)")
            self.saveOrUpdateLog(text: expirationText)
        }
        
        //成功处理回调通知,因为是作为在Swifter的successHanler来调用，所以如下格式
        let completeHandler: () -> () = {
            
            let successText = "BGAPPRefreshTask completed."
            self.alerts.setLogMessage(text: "\(self.timeStamp) \(successText)")
            self.saveOrUpdateLog(text: successText)
            
            task.setTaskCompleted(success: true)
        }
        
        //logHandler用来传入到其他函数中接受记录并输出信息到CoreData中
        let _: (String) -> () = {logText in
            self.alerts.setLogMessage(text: logText)
            self.saveOrUpdateLog(text: logText)
        }
        
        //失败回调闭包用来获取推文失败是调用，会记录失败信息
        //并标注任务结束，但是是失败状态（不知道这个标注成失败和成功会有什么区别）
        //        let failureHandler:(Error) -> Void = { error in
        //            logHandler(error.localizedDescription)
        //            task.setTaskCompleted(success: false)
        //        }
        
        //实际操作部分，执行真正的操作
        guard store.appState.setting.loginUser != nil else { return }
        
        saveOrUpdateLog(text: "Started background fetch.")
        
        bgFetchTask(completeHandler)
        
        
        ///暂时取消删推功能
        //        if loingUser.setting.isDeleteTweets {
        //
        //            swifter.fastDeleteTweets(for: loingUser.info.id,
        //                                     keepRecent: loingUser.setting.isKeepRecentTweets,
        //                                     completeHandler: completeHandler,
        //                                     logHandler: logHandler)
        //
        //        } else {
        //            completeHandler()
        //        }
    }
    
    
    func handleProcess(task: BGProcessingTask) {
        scheduledProcess()
        
        task.expirationHandler = {
            let expirationText = "BGProcessingTask unexpectedly exit."
            self.saveOrUpdateLog(text: expirationText)
        }
        
        //成功处理回调通知，具体形式不一定，取决于执行的任务对成功回调闭包的要求。
        let successHandler: () -> Void = {
            
            let successText = "BGProcessingTask completed."
            self.saveOrUpdateLog(text: successText)
            
            task.setTaskCompleted(success: true)
        }
        
        //实际操作部分，但如果操作内容为空则写入log并结束
        Count.cleanCountData(success: successHandler, before: 7.0, context: context)
        
    }
}

//MARK:-CoreData操作
extension SceneDelegate {
    
    func saveOrUpdateLog(text: String?){
        guard text != nil else {return}
        
        let log = Log(context: context)
        log.createdAt = Date()
        log.text = " \(store.appState.setting.loginUser?.screenName ?? "screenName") " + text! //临时添加一个用户名做标记
        log.id = UUID()
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print(nsError.description)
            
        }
        
    }
    
}
