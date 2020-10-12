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

struct HubView: View {
    
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    @EnvironmentObject var downloader: Downloader
    
    @StateObject var home = Timeline(type: TweetListType.home)
    @StateObject var mention = Timeline(type: TweetListType.mention)
    @StateObject var message = Timeline(type: .message)
    
    
    @State var toolsBarViews: [ToolBarView] = []
    
    @State var tweetText: String = ""
    
    var body: some View {
        
        NavigationView {
            ZStack{
                LogoBackground()
            ScrollView(/*@START_MENU_TOKEN@*/.vertical/*@END_MENU_TOKEN@*/, showsIndicators: false){
                ZStack{
                   
                    RoundedCorners(color: Color.init("BackGround"), tl: 18, tr: 18, bl: 0, br: 0)
                        .padding(.top, 0)
                        .padding(.bottom, -164)
                        .shadow(radius: 3 )
                    
                    
                    
                    VStack {
                        PullToRefreshView(action: {self.refreshAll()}, isDone: self.$home.isDone) {
                            ComposerOfHubView(tweetText: $tweetText)
                                .padding(.top, 16)
                                .padding([.leading, .trailing], 18)
                        }.frame(height: 180)
                        
                        
                        //Timeline
                        VStack {
                            HStack {
                                Text("Timeline").font(.caption).bold().foregroundColor(Color.gray)
                                Spacer()
                            }.padding(.leading,16).padding(.top, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    TimelineIconView(timeline: home)
                                    TimelineIconView(timeline: mention)
                                    TimelineIconView(timeline: message)
                                    ForEach(user.myInfo.lists.keys.sorted(), id: \.self) { listName in
                                        TimelineIconView(timeline: Timeline(type: .list, listTag: user.myInfo.lists[listName]), listName: listName)
                                    }
                                    
                                }.padding(.top, 8).padding(.bottom, 8).padding(.leading, 16)
                            }.padding(0)
                        }
                        
                        
                        //Tools
                        VStack( spacing: 16) {
                            HStack {
                                Text("Tools").font(.caption).bold().foregroundColor(Color.gray)
                                Spacer()
                            }
                 
                            ForEach(toolsBarViews) {
                                view in
                                view
                            }.onDelete(perform: { indexSet in
                                toolsBarViews.remove(atOffsets: indexSet)
                            })
                            
                        }.padding([.leading, .trailing, .bottom], 16)
                        
                        
                    }
                    
                    //通知视图
                    VStack(spacing: 0) {
                        if self.alerts.stripAlert.isPresentedAlert {
                            AlertView(isAlertShow: self.$alerts.stripAlert.isPresentedAlert, alertText: self.alerts.stripAlert.alertText)
                        }
                        Spacer()
                    }
                    .clipped() //通知条超出范围部分被裁减，产生形状缩减的效果
                }
                .onAppear{
                    self.setBackgroundFetch()
                    if toolsBarViews.isEmpty {
                        addToolBarView(type: .friends)
                        addToolBarView(type: .tweets)
                        addToolBarView(type: .tools)
                    }
                }
                
            }
            }
            .navigationTitle("FetchMee")
            .navigationBarItems(trailing:NavigationLink(destination: SettingView()) {
                Image(uiImage: (self.user.myInfo.avatar ?? UIImage(systemName: "person.circle.fill")!))
                    .resizable()
                    .frame(width: 32, height: 32, alignment: .center)
                    .clipShape(Circle())
                
            })
        }
        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
            self.hideKeyboard()
        })
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
        self.mention.refreshFromTop()
        self.home.refreshFromTop(completeHandeler: completeHandler)
    }
    
    
    func refreshAll() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred() //产生震动提示
        self.home.refreshFromTop()
        self.mention.refreshFromTop()
        self.user.getMyInfo()
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func addToolBarView(type: ToolBarViewType) {
        switch type {
        case .friends:
            let toolBarView = ToolBarView(type: type,
                                          label1Value: $user.myInfo.followed,
                                          label2Value: $user.myInfo.following,
                                          label3Value: .constant(88))
            self.toolsBarViews.append(toolBarView)
        case .tweets:
            let toolBarView = ToolBarView(type: type,
                                          label1Value: $user.myInfo.tweetsCount,
                                          label2Value: $user.myInfo.tweetsCount,
                                          label3Value: .constant(88))
            self.toolsBarViews.append(toolBarView)
        case .tools:
            let toolBarView = ToolBarView(type: type,
                                          label1Value: $user.myInfo.tweetsCount,
                                          label2Value: $user.myInfo.tweetsCount,
                                          label3Value: .constant(88))
            
            self.toolsBarViews.append(toolBarView)
        }
    }
}



