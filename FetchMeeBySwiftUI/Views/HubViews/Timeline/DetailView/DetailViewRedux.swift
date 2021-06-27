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
    var status: Status
    
    
    var body: some View {
        GeometryReader{proxy in
            List {
                
                RoundedCorners(color: Color.init("BackGround"), tl: 24, tr: 24, bl: 0, br: 0)
                    .frame(height: 42)
                    .foregroundColor(Color.init("BackGround"))
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                ForEach([status],
//                    store.appState.timelineData.getTimeline(timelineType: .session).status,
                    id: \.id) {status in
                    
                        
                            StatusRow(status: status,
                                      width: proxy.size.width - 2 * 16)
                                .background(store.appState.setting.userSetting?.uiStyle.backGround)
                                .cornerRadius(16, antialiased: true)
                                .overlay(RoundedRectangle(cornerRadius: 16)
                                            .stroke(store.appState.setting.userSetting?.uiStyle.backGround ?? Color.black, lineWidth: 1))
                                .padding(.horizontal, store.appState.setting.userSetting?.uiStyle.insetH)
                                .padding(.vertical, store.appState.setting.userSetting?.uiStyle.insetV)
                            
                                .background(Color.init("BackGround")) //这个background可以遮蔽List的分割线
                            if store.appState.setting.userSetting?.uiStyle == .plain {
                                Divider().padding(0)
                            }
                }
                .listRowBackground(Color.init("BackGround"))
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                DetailInfoView(status: status )
                    .padding(.vertical,16)
                    .frame(height: 100)
                    .listRowBackground(Color.init("BackGround"))
                
                Composer(tweetTextBinding: $store.appState.setting.tweetInput.tweetText,
                         isProcessingDone: $store.appState.setting.isProcessingDone,
                         status: status)
                    .frame(height: 42)
                    .listRowBackground(Color.accentColor.opacity(0.4))
                
                RoundedCorners(color: Color.init("BackGround"), tl: 0, tr: 0, bl: 24, br: 24)
                    .frame(height: 64)
                    .foregroundColor(Color.init("BackGround"))
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .listStyle(.plain)
            .listRowBackground(Color.init("BackGround"))
            .navigationTitle("Detail")
            .onDisappear(perform: {print("Disappear of DeltialView \(status.id)")})
            .refreshable(action: {
//                store.dispatch(.fetchSession(tweetIDString: status.id))
            })
        }
    }
}

struct DetailViewRedux_Previews: PreviewProvider {
    static var previews: some View {
        DetailViewRedux(status: Status())
            .environmentObject(Store())
    }
}
