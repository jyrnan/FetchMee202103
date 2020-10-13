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
    
    @State var tweetText: String = ""
    
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
                            
                            TimelinesView()
                            
                            ToolBarsView()
                                .padding([.leading, .trailing, .bottom], 16)
                            
                            Spacer()
                            
                            HStack {
                                Spacer()
                                Text("Developed by @jyrnan").font(.caption2).foregroundColor(Color.gray)
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
        user.home.refreshFromTop(completeHandeler: completeHandler)
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



