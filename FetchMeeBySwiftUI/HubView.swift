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

struct HubView: View {
    
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    @EnvironmentObject var downloader: Downloader
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var tweetText: String = ""
//    @State var BGTaskInfoText: String = "Preparing Next Task"
    
    var body: some View {
        
        NavigationView {
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
                            }.frame(height: 180)
                            
                            Divider()
                            TimelinesView()
                            
                            ToolBarsView()
                                .padding([.leading, .trailing, .bottom], 16)
                            
                            HStack {
                                Text(alerts.logInfo.alertText).font(.caption2).foregroundColor(.gray).opacity(0.5)
                            }
                            
                            Spacer()
                            
                            
                            
                            HStack {
                                Spacer()
                                Button(action: {
                                    if user.myInfo.setting.isDeleteTweets {
                                        deleteTweets {
                                            alerts.stripAlert.alertText = "Some tweets deleted."
                                            alerts.stripAlert.isPresentedAlert = true
                                        }
                                    }
                                }){Text("Developed by @jyrnan").font(.caption2).foregroundColor(Color.gray)}
                                    
                                Spacer()
                            }.padding(.top, 20).padding()
                            
                        }
                        
                        AlertView()
                    }
                }
            }
            .navigationTitle("FetchMee")
            .navigationBarItems(trailing: NavigationLink(destination: SettingView()) {
                AvatarImageView(image: user.myInfo.avatar)
            })
        }
        .onAppear{self.setBackgroundFetch()}
        .onTapGesture(count: 1, perform: {self.hideKeyboard()})
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
        backgroudnFetch = self.backgroundFetch
    }
    
    /// 后台刷新的具体操作内容
    /// - Parameter task: 传入的task
    /// - Returns: Void
    func backgroundFetch(task: BGAppRefreshTask) -> Void {
        let completeHandler = {task.setTaskCompleted(success: true)}
        user.mention.refreshFromTop()
        
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
        user.home.refreshFromTop()
        user.mention.refreshFromTop()
        user.getMyInfo()
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//MARK:-扩充后台删除推文方法
extension HubView {
    
    
    /// 用于后台删除推文的方法
    /// - Parameter completeHandler: 传入作为所有任务全部完成后的成功回调，主动通知系统后台任务可以结束
    func deleteTweets(completeHandler: @escaping ()->()) {
        
        ///获取待删除的推文的方法
        func getTweets(json: JSON) {
            let newTweets = json.array ?? []
            guard !newTweets.isEmpty else {
                self.alerts.logInfo.alertText = "\(timeNow) No tweets deleted."
                return
            }
            
            deletedTweetCount = newTweets.count
            
            for newTweet in newTweets {
                if let idString = newTweet["id_str"].string {
                    tweetsTobeDel.append(idString)
                }
            }
        }
        
        func fh(error: Error) -> Void {
            self.alerts.logInfo.alertText = "\(timeNow) Deleting tweets failed."
        }
        
        //获取推文成功处理闭包，成功后会调用删除推文方法
        func getSH(json: JSON) -> Void {
           getTweets(json: json)
            
            //开始删除推文
            guard !tweetsTobeDel.isEmpty else {return}
            //
            let tweetWillDel = tweetsTobeDel.removeLast()
            swifter.destroyTweet(forID: tweetWillDel, success: delSH(json:), failure: fh)
        }
        
        func delSH(json: JSON) -> Void {
            //这里判断如果所有需要被删除的推文都已经完成，则可以调用最终的completeHandler
            guard !tweetsTobeDel.isEmpty else {
                
                //传递文字并保存到Draft的CoreData数据中
                self.alerts.logInfo.alertText = "\(timeNow) \(deletedTweetCount) tweets deleted."
                saveOrUpdateDraft()
                completeHandler()
                return
            }
            
            let tweetWillDel = tweetsTobeDel.removeLast()
            swifter.destroyTweet(forID: tweetWillDel, success: delSH(json:))
        }
        
        //这里是方法的真正入口
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.timeZone = .current
        let timeNow = formatter.string(from: now)
        
        var tweetsTobeDel: [String] = []
        var deletedTweetCount: Int = 0
        let userIDString = self.user.myInfo.id
        swifter.getTimeline(for: UserTag.id(userIDString ), count: 3,success: getSH, failure: fh)
    }
}

//MARK:-CoreData操作模块
extension HubView {
    private func saveOrUpdateDraft(draft: TweetDraft? = nil){
        withAnimation {
            let draft = draft ?? TweetDraft(context: viewContext) //如果没有当前编辑的draft则新生成一个空的draft
            draft.createdAt = Date()
            draft.text = alerts.logInfo.alertText //先用这个代替
            
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")}
        }
    }
    
    private func deleteDraft(draft: TweetDraft?) {
        guard draft != nil else {return}
        
        viewContext.delete(draft!)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

