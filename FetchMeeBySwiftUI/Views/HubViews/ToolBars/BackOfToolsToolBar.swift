//
//  BackOfToolsToolBar.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/16.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine

struct BackOfToolsToolBar: View {
    @EnvironmentObject var fetchMee: AppData
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                let completeHandler  = {print(#line, #function, "Tweet deleted")}
                let lh: (String) -> () = {string in}
                
                swifter.fastDeleteTweets(for: fetchMee.myInfo.id, willDeleteCount: 2, keepRecent: fetchMee.myInfo.setting.isKeepRecentTweets,  completeHandler: completeHandler, logHandler: lh)
            }, label: {
                VStack{
                    Image(systemName: "message.circle.fill").font(.title2)
                    Text("SayHello").font(.caption).padding(.top, 1)
                }
            })
            Spacer()
            
            Button(action: {
                guard let windowsScenen = UIApplication.shared.connectedScenes.first as? UIWindowScene ,
                      let sceneDelegate = windowsScenen.delegate as? SceneDelegate
                else {
                    return
                }
//                sceneDelegate.cleanCountdata()
            }, label: {
                VStack{
                    Image(systemName: "heart.fill").font(.title2)
                    Text("LikeYou").font(.caption).padding(.top, 1)
                    }
            })
            
            Spacer()
            
            Button(action: {
                //测试获取Following IDS
//                let userTag = UserTag.id(user.myInfo.id)
//                swifter.getUserFollowersIDs(for: userTag, success: {json, _, _ in
//                    print(json.array?.count)
//                    
//                    
//                })
                withAnimation{
                    fetchMee.isShowingPicture = true
                    fetchMee.presentedView = AnyView(Image(systemName: "person").resizable().aspectRatio(contentMode: .fit).foregroundColor(.accentColor))
                }
                
            }, label: {
                VStack{
                    Image(systemName: "sun.max.fill").font(.title2)
                    Text("Morning").font(.caption).padding(.top, 1)
                    }
            })
            
            Spacer()
            
            NavigationLink(destination: UserMarkManageView()){
                VStack{
                    Image(systemName: "person.fill.questionmark").font(.title2)
                    Text("UserMark").font(.caption).padding(.top, 1)
                    }
            }
            
            Spacer()
            
        }.foregroundColor(.white)
        .padding()
    }
}

struct BackOfToolsToolBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(.blue).shadow(color: Color.black.opacity(0.2),radius: 3, x: 0, y: 3).frame(height: 76)
            BackOfToolsToolBar()
        }
    }
}

extension BackOfToolsToolBar {
    
    func getRateLimits() {
        swifter.getRateLimits(for: ["statuses"], success: {
            json in
            print(json)
        }, failure: nil)
    }
}
