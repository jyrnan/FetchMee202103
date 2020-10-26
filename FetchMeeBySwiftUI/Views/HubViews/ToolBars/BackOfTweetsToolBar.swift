//
//  BackOfTweetsToolBar.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/17.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine

struct BackOfTweetsToolBar: View {
    let autoDeletWarningMessage: String = "Selecting Auto Delete tweets will automatically delete them in the background. Due to api restrictions, approximately 80 tweets are deleted per hour. Please keep the application background refresh open. If you need to keep your recent tweets, make sure the Keep Recent switch is on. \n Are you sure?"
    let manualDeleteWarningMessage: String = "Selecting Manual Delete will immediately delete up to 300 sauces at once. Due to api limits, the app will automatically calculate the maximum number of tweets that can be deleted and delete them. If you need to keep your recent tweets, make sure the Keep Recent switch is on."
    
    @EnvironmentObject var user: User
    @EnvironmentObject var alerts: Alerts
    
    @State var isShowManualDeleteAlert: Bool = false
    
   
    
    var body: some View {
        VStack {
            HStack{
                Toggle(isOn: $user.myInfo.setting.isDeleteTweets) {
                    Text("Auto\nDelete")
                        .font(.caption).bold()
                        .foregroundColor(.white)
                }
                .alert(isPresented: $user.myInfo.setting.isDeleteTweets){
                                            Alert(title: Text("Attention"),
                                                  message: Text(autoDeletWarningMessage),
                                                  primaryButton: .destructive(Text("Sure"), action: {user.myInfo.setting.isDeleteTweets = true}),
                                                  secondaryButton: .cancel())}
                
                Divider()
                Toggle(isOn: $user.myInfo.setting.isKeepRecentTweets) {
                    Text("Keep\nRecent").font(.caption).bold()
                        .foregroundColor(.white)
                }
                
                Divider()
                
                //快速删除按钮
                Button(action: {isShowManualDeleteAlert = true},
                       label: {
                    HStack{
                        
                        Text("Manual\nDelete").font(.caption).bold()
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "trash.circle.fill").font(.title).foregroundColor(.white)
                    }
                })
                .alert(isPresented: $isShowManualDeleteAlert){
                                            Alert(title: Text("Attention"),
                                                  message: Text(manualDeleteWarningMessage),
                                                  primaryButton: .destructive(Text("Delete"),
                                                                              action: { manualDelete()}),
                                                  secondaryButton: .cancel())}
            }
//            HStack {
//                Spacer()
//                Text("\"Keep Recent\" on to reserve last 80 tweets ")
//                    .foregroundColor(.white).font(.caption2)
//            }
        }
        .padding([.leading, .trailing], 12)
//        .fixedSize()
    }
}
struct BackOfTweetsToolBar_Previews: PreviewProvider {
    static var previews: some View {
        BackOfTweetsToolBar()
    }
}

extension BackOfTweetsToolBar {
    fileprivate func manualDelete() {
        let completeHandler  = {
            print(#line, #function, "Tweet deleted")
        }
        let lh: (String) -> () = {string in
            self.alerts.setLogInfo(text: string)
        }
        swifter.fastDeleteTweets(for: user.myInfo.id,
                                 keepRecent: user.myInfo.setting.isKeepRecentTweets,
                                 completeHandler: completeHandler,
                                 logHandler: lh)
    }
}