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

var swifter: Swifter = Swifter(consumerKey: "wa43gWPPaNLYiZCdvZLXlA",
                               consumerSecret: "BvKyqaWgze9BP3adOSTtsX6PnBOG5ubOwJmGpwh8w")


let userDefault = UserDefaults.init()
let cfh = CacheFileHandler() //设置下载文件的缓存位置
let session = URLSession.shared

//两个用来实现后台运行的函数变量，会依据情况不同代表不同的执行内容
var backgroundFetchTask: ((BGAppRefreshTask) -> Void)?
var backgroundProcessTask: ((BGProcessingTask) -> Void)?

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var fetchMee: AppData = AppData() //App登录使用的用户
    var alerts: Alerts = Alerts()
    var downloader = Downloader(configuation: URLSessionConfiguration.default)
    
    let context = PersistenceContainer.shared.container.viewContext
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // Create the SwiftUI view that provides the window contents.
        self.fetchMee.isLoggedIn = userDefault.object(forKey: "isLoggedIn") as? Bool ?? false
        self.fetchMee.loginUser.setting.load() //读取存储多设置
        let contentView = ContentView().environment(\.managedObjectContext, context)
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            if self.fetchMee.isLoggedIn {
                // 读取token信息
                let tokenKey = userDefault.object(forKey: "tokenKey") as! String
                let tokenSecret = userDefault.object(forKey: "tokenSecret") as! String
                //设置登录后的Swifter以及获取loginUser的信息
                swifter = Swifter(consumerKey: "wa43gWPPaNLYiZCdvZLXlA",
                                  consumerSecret: "BvKyqaWgze9BP3adOSTtsX6PnBOG5ubOwJmGpwh8w",
                                  oauthToken: tokenKey,
                                  oauthTokenSecret: tokenSecret)
                
                self.fetchMee.getMyInfo()}
            
            window.rootViewController = UIHostingController(rootView: contentView
                                                                .environmentObject(alerts).environmentObject(fetchMee)
                                                                .accentColor(self.fetchMee.loginUser.setting.themeColor.color).environmentObject(downloader))
            
            
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
        fetchMee.loginUser.setting.save()
        
        //加入定时程序
        scheduledRefresh()
        scheduledProcess()
        
        
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
            self.alerts.setLogInfo(text: "\(self.timeStamp) \(taskSetText)")
            
            
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
            self.alerts.setLogInfo(text: "\(self.timeStamp) \(taskSetText)")
            
            
        } catch {
            print("Could not schedule database cleaning: \(error)")
        }
    }
    
    // MARK: - Handling Launch for Tasks
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduledRefresh()
        
        task.expirationHandler = {
            let expirationText = "BGAPPRefreshTask unexpectedly exit."
            
            self.alerts.setLogInfo(text: "\(self.timeStamp) \(expirationText)")
            self.saveOrUpdateLog(text: expirationText)
        }
        
        //成功处理回调通知,因为是作为在Swifter的successHanler来调用，所以如下格式
        let completeHandler: () -> () = {
            
            let successText = "BGAPPRefreshTask completed."
            self.alerts.setLogInfo(text: "\(self.timeStamp) \(successText)")
            self.saveOrUpdateLog(text: successText)
            
            task.setTaskCompleted(success: true)
        }
        
        //logHandler用来传入到其他函数中接受记录并输出信息到CoreData中
        let logHandler: (String) -> () = {logText in
            self.alerts.setLogInfo(text: logText)
            self.saveOrUpdateLog(text: logText)
        }
        
        //实际操作部分，执行真正的操作
        guard fetchMee.isLoggedIn else { return }
        
        saveOrUpdateLog(text: "Started background fetch.")
        fetchMee.mention.refreshFromTop()
        
        if fetchMee.loginUser.setting.isDeleteTweets {
            
            fetchMee.home.refreshFromTop()
            swifter.fastDeleteTweets(for: fetchMee.loginUser.id,
                                     keepRecent: fetchMee.loginUser.setting.isKeepRecentTweets,
                                     completeHandler: completeHandler,
                                     logHandler: logHandler)
            
        } else {
            fetchMee.home.refreshFromTop(completeHandeler: completeHandler)
        }
    }
    
    
    func handleProcess(task: BGProcessingTask) {
        scheduledProcess()
        
        task.expirationHandler = {
            let expirationText = "BGProcessingTask unexpectedly exit."
            self.saveOrUpdateLog(text: expirationText)
        }
        
        //成功处理回调通知，具体形式不一定，取决于执行的任务对成功回调闭包的要求。
        let successHandler: (JSON) -> Void = {json in
            
            let successText = "BGProcessingTask completed."
            self.saveOrUpdateLog(text: successText)
            
            task.setTaskCompleted(success: true)
        }
        
        //实际操作部分，但如果操作内容为空则写入log并结束
       cleanCountdata()
        
    }
}

//MARK:-CoreData操作
extension SceneDelegate {
    
    func saveOrUpdateLog(text: String?){
        guard text != nil else {return}
        withAnimation {
            let log = Log(context: context)
            log.createdAt = Date()
            log.text = " \(fetchMee.loginUser.screenName ?? "screenName") " + text! //临时添加一个用户名做标记
            log.id = UUID()
            
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")}
        }
    }
    
    func cleanCountdata() {
        let sevenDays: TimeInterval = -(60 * 60 * 24 * 7)
        
        
        let timeIntervalPredicate: NSPredicate = NSPredicate(format: "%K <= %@", #keyPath(Count.createdAt), Date().addingTimeInterval(sevenDays) as CVarArg)
        let fetchRequest: NSFetchRequest<Count> = Count.fetchRequest()
        fetchRequest.predicate = timeIntervalPredicate
        
        do {
            let counts = try context.fetch(fetchRequest)
            
            counts.forEach{context.delete($0)}
            
            try context.save()
            
        } catch let error as NSError {
            print("count not fetched \(error), \(error.userInfo)")
          }
    }
    
}
