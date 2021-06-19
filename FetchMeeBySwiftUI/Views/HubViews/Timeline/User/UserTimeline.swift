//
//  UserTimeline.swift
//  FetchMee
//
//  Created by jyrnan on 2021/4/4.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI

struct UserTimeline: View {
    @EnvironmentObject var store:Store
    var userIDString: String
    var width: CGFloat
    
    
    var userTimeline: AppState.TimelineData.Timeline {
        store.appState.timelineData.timelines[TimelineType.user(userID: userIDString).rawValue] ??
        AppState.TimelineData.Timeline(type:.user(userID: userIDString))}
    
    ///创建一个简单表示法
    var setting: UserSetting {store.appState.setting.userSetting ?? UserSetting()}
    
    var body: some View {
        
            ForEach(userTimeline.tweetIDStrings, id: \.self) {
                tweetIDString in
                if tweetIDString != "toolsViewMark" {
                    VStack(spacing: 0){
                        StatusRow(status: store.repository.getStatus(byID: tweetIDString), width: width - 2 * setting.uiStyle.insetH)
                            .background(setting.uiStyle.backGround)
                            .cornerRadius(setting.uiStyle.radius, antialiased: true)
                            .overlay(RoundedRectangle(cornerRadius: setting.uiStyle.radius)
                                        .stroke(setting.uiStyle.backGround, lineWidth: 1))
                            .padding(.horizontal, setting.uiStyle.insetH)
                            .padding(.vertical, setting.uiStyle.insetV)
                            ///下面这个background可以遮蔽List的分割线
                            .background(Color.init("BackGround"))
                        
                        if setting.uiStyle == .plain {
                            Divider().padding(0)
                        }
                    }
                }
                
            }
            .listRowBackground(Color.init("BackGround"))
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            //下方载入更多按钮
            
            HStack {
                Spacer()
                Button("More Tweets...") {
                    store.dispatch(.fetchTimeline(timelineType: .user(userID: userIDString), mode: .bottom))
                }
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
                Spacer()
            }
            .listRowBackground(Color.init("BackGround"))
            
            RoundedCorners(color: Color.init("BackGround"), tl: 0, tr: 0, bl: 24, br: 24)
                .frame(height: 42)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        
        .onAppear{
//            store.dispatch(.fetchTimeline(timelineType: .user(userID: userIDString), mode: .top))
        }
    }
}

struct UserTimeline_Previews: PreviewProvider {
    static var previews: some View {
        UserTimeline(userIDString: "", width: 300)
    }
}
