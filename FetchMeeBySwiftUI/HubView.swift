//
//  HubView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/10.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import BackgroundTasks
import Swifter
import CoreData

struct HubView: View {
    
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    @EnvironmentObject var downloader: Downloader
   
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetDraft.createdAt, ascending: true)]) var logs: FetchedResults<Log>
    
    @State var tweetText: String = ""
    
    var body: some View {
        
        NavigationView {
            GeometryReader {geometry in
            ZStack{
                LogoBackground()
                ScrollView(.vertical, showsIndicators: false){
                    
                    ZStack{
                        
                        RoundedCorners(color: Color.init("BackGround"), tl: 18, tr: 18, bl: 0, br: 0)
                            .padding(.top, 0)
                            .padding(.bottom, 0)
                            .shadow(radius: 3 )
                        
                        
                        VStack {
                            PullToRefreshView(action: {self.refreshAll()}, isDone: $user.home.isDone) {
                                ComposerOfHubView(tweetText: $tweetText)
                                    .padding(.top, 16)
                                    .padding([.leading, .trailing], 18)
                            }
                            .frame(height: geometry.size.height - 428 > 0 ? geometry.size.height - 428 : 180)
                            
                            Divider()
                            TimelinesView()
                            
                            ToolBarsView()
                                .padding([.leading, .trailing], 16)
                            
                            HStack {
                                NavigationLink(destination: LogMessageView()){
                                    Text(alerts.logInfo.alertText == "" ? "No new log message" : alerts.logInfo.alertText)
                                    .font(.caption2).foregroundColor(.gray).opacity(0.5)
                            }
                            }
                            
                            Spacer()
                            
                            
                            
                            HStack {
                                Spacer()
                                Button(action: {
                                    //用来检测后台运行删推程序以及刷新状况
//                                    if user.myInfo.setting.isDeleteTweets {
//                                        deleteTweets {
//                                            alerts.stripAlert.alertText = "Some tweets deleted."
//                                            alerts.stripAlert.isPresentedAlert = true
//                                        }
//                                    } else {
//                                        refreshAll()
//                                    }
                                    print(#line, geometry.size.debugDescription)
                                }){Text("Developed by @jyrnan").font(.caption2).foregroundColor(Color.gray)}
                                    
                                Spacer()
                            }.padding(.top, 20).padding()
                            
                        }
                        
                        AlertView()
                    }
                   
                }
            }.fixedSize(horizontal: false, vertical: true)
            .onTapGesture(count: 1, perform: {self.hideKeyboard()})
            .navigationTitle("FetchMee")
            .navigationBarItems(trailing: NavigationLink(destination: SettingView()) {
                AvatarImageView(image: user.myInfo.avatar).frame(width: 36, height: 36, alignment: .center)})
            }
        }
        .onAppear{self.setBackgroundFetch()}
//        .onTapGesture(count: 1, perform: {self.hideKeyboard()})
    }
}

struct HubView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            HubView().environmentObject(User())
            HubView().environmentObject(User()).environment(\.colorScheme, .dark)
        }
    }
}

//MARK:-设置后台刷新的内容
extension HubView {
    /// 设置后台刷新的内容
    func setBackgroundFetch() {
        backgroundFetchTask = self.backgroundFetch
    }
    
    /// 后台刷新的具体操作内容
    /// - Parameter task: 传入的task
    /// - Returns: Void
    func backgroundFetch(task: BGAppRefreshTask) -> Void {
        let completeHandler = {task.setTaskCompleted(success: true)}
        user.mention.refreshFromTop()
        
        saveOrUpdateLog(text: "Started background fetch.")
        
        if !user.myInfo.setting.isDeleteTweets {
            user.home.refreshFromTop(completeHandeler: completeHandler)
        }
        
        if user.myInfo.setting.isDeleteTweets {
            user.home.refreshFromTop()
            deleteTweets(completeHandler: completeHandler)
        }
    }
    
    func backgroundProcessing(task: BGProcessingTask) -> Void {
        let completeHandler = {task.setTaskCompleted(success: true)}
        user.mention.refreshFromTop()
        
        saveOrUpdateLog(text: "Started background processing.")
        
        if !user.myInfo.setting.isDeleteTweets {
            user.home.refreshFromTop(completeHandeler: completeHandler)
        }
        
        if user.myInfo.setting.isDeleteTweets {
            user.home.refreshFromTop()
            deleteTweets(completeHandler: completeHandler)
        }
    }
    
    
    func refreshAll() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred() //产生震动提示
        user.home.refreshFromTop(completeHandeler: {
                                    alerts.logInfo.alertText = "Fetching ended."
//                                    saveOrUpdateLog(text: "Fetching ended.")
            
        })
        user.mention.refreshFromTop()
        user.getMyInfo()
        alerts.logInfo.alertText = "Started fetching new tweets..."
//        saveOrUpdateLog(text: "Started fetching new tweets...")
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//MARK:-扩充后台删除推文方法
extension HubView {
    
    /// 用于后台删除推文的方法。结合每次执行时间是15分钟，所以每次删除20条推文比较合适
    /// - Parameter completeHandler: 传入作为所有任务全部完成后的成功回调，主动通知系统后台任务可以结束
    func deleteTweets(completeHandler: @escaping ()->()) {
        
        //3 准备好待删除的推文的方法
        func prepareTweetsForDeletion(json: JSON) {
            var tweetsForDeletion = json.array ?? []
            
            if user.myInfo.setting.isKeepRecentTweets {
            //如果超过80个，则去除前80个以不被删除
            if tweetsForDeletion.count >= 80 {
                tweetsForDeletion.removeFirst(80)}
            else {
                tweetsForDeletion.removeAll()
            }
            
            }
            //如果要删除的推文数量为零，则直接退出并输出信息
            guard !tweetsForDeletion.isEmpty else {
                self.alerts.logInfo.alertText = "<\(timeNow)> No tweets deleted."
                saveOrUpdateLog(text: "No tweets deleted.")
                return
            }
            
            //记录将要删除的推文数量
            deletedTweetCount = tweetsForDeletion.count
            
            //把需要删除的推文id提取出来添加到删除队列tweetsTobeDel
            for tweet in tweetsForDeletion {
                if let idString = tweet["id_str"].string {
                    tweetsTobeDel.append(idString)
                }
            }
        }
        
        func fh(error: Error) -> Void {
            self.alerts.logInfo.alertText = "<\(timeNow)> Deleting task failed."
            saveOrUpdateLog(text: "Deleting task failed.")
        }
        
        //2 获取推文成功处理闭包，成功后会调用删除推文方法
        func getSH(json: JSON) -> Void {
           prepareTweetsForDeletion(json: json)
            
            //4开始删除推文。
            //下面的判断必须要。因为tweetsTobeDel有可能为空，不会执行删推方法，
            //所以需要调用completeHandler，并返回结束
            guard !tweetsTobeDel.isEmpty else {
                completeHandler()
                return}
            
            let tweetWillDel = tweetsTobeDel.removeLast()
            swifter.destroyTweet(forID: tweetWillDel, success: delSH(json:), failure: fh)
        }
        
        func delSH(json: JSON) -> Void {
            //这里判断如果所有需要被删除的推文都已经完成，则可以调用最终的completeHandler
            guard !tweetsTobeDel.isEmpty else {
                
                //传递文字并保存到Draft的CoreData数据中
                self.alerts.logInfo.alertText = "About \(deletedTweetCount) tweets deleted."
                saveOrUpdateLog(text: "About \(deletedTweetCount) tweets deleted.")
                completeHandler()
                return
            }
            
            let tweetWillDel = tweetsTobeDel.removeLast()
            swifter.destroyTweet(forID: tweetWillDel, success: delSH(json:))
        }
        
        
        /// 获取当前的时间
        /// - Returns: 当前时间的字串
        func getTimeNow() -> String {
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .long
            formatter.timeZone = .current
            let timeNow = formatter.string(from: now)
            return timeNow
        }
        
        //1 这里是方法的真正入口
        let timeNow = getTimeNow()
        
        var tweetsTobeDel: [String] = [] //将要删除的推文的id序列
        var deletedTweetCount: Int = 0 //将要删除的推文数量
        let userIDString = self.user.myInfo.id
        
        //一次读取推文数量，该值决定了保留最新推文的数量，保留推文数量设置默认为80条，所以最多读取100条
        let maxCount: Int = {
            switch user.myInfo.setting.isKeepRecentTweets {
            case true:
                return 100
            case false:
                return 20
            }
        }()
        
        swifter.getTimeline(for: UserTag.id(userIDString ),
                            count: maxCount,
                            success: getSH,
                            failure: fh)
    }
}

//MARK:-CoreData操作模块
extension HubView {
    private func saveOrUpdateLog(text: String?){
        withAnimation {
            let log = Log(context: viewContext)
            log.createdAt = Date()
            log.text = text
            log.id = UUID()
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")}
        }
    }
    
    private func deleteLog(log: Log?) {
        guard log != nil else {return}
        
        viewContext.delete(log!)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

