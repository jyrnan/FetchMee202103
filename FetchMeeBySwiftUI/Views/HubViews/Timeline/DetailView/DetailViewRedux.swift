//
//  DetailViewRedux.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/27.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import Swifter

struct DetailViewRedux: View {
    @EnvironmentObject var store: Store
    
    ///创建一个简单表示法
    var setting: UserSetting {store.appState.setting.userSetting ?? UserSetting()}
    var tweetIDString: String //传入DetailView的初始推文
    
    var session: AppState.TimelineData.Timeline {store.appState.timelineData.getTimeline(timelineType: .session)}
    var status: Status {store.repository.statuses[tweetIDString] ?? Status(id: "0000")}
    
    @State var firstTimeRun: Bool = true //检测用于运行一次
    
    
    var body: some View {
        GeometryReader{proxy in
                List {
                   
                    RoundedCorners(color: Color.init("BackGround"), tl: 24, tr: 24, bl: 0, br: 0)
                        .frame(height: 42)
                        .foregroundColor(Color.init("BackGround"))
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    ForEach(session.tweetIDStrings, id: \.self) {tweetIDString in
                        if tweetIDString != "toolsViewMark" {
                            VStack(spacing: 0){
                                StatusRow(tweetID: tweetIDString, width: proxy.size.width - 2 * setting.uiStyle.insetH, rowType: .session)
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
                        
                    DetailInfoView(status: status )
                            .padding(.vertical,16)
                            .frame(height: 100)
                            .listRowBackground(Color.init("BackGround"))
                        
                    Composer(isProcessingDone: $store.appState.setting.isProcessingDone, tweetIDString: tweetIDString)
                        .frame(height: 42)
                            .listRowBackground(Color.accentColor.opacity(0.4))
                   
                    RoundedCorners(color: Color.init("BackGround"), tl: 0, tr: 0, bl: 24, br: 24)
                        .frame(height: 64)
                        .foregroundColor(Color.init("BackGround"))
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                   
                }
                .listRowBackground(Color.init("BackGround"))
                .navigationTitle("Detail")
        }
    }
}

struct DetailViewRedux_Previews: PreviewProvider {
    static var previews: some View {
        DetailViewRedux(tweetIDString: "0000")
    }
}
