//
//  DetailViewSheet.swift
//  FetchMee
//
//  Created by jyrnan on 2021/6/28.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import Swifter

struct DetailViewSheet: View {
    @EnvironmentObject var store: Store
    var status: Status
    init(status: Status) {
        self.status = status
        print( "Init of DeatailViewSheet")
    }
    
    var body: some View {
        GeometryReader{proxy in
            ScrollView {
                Rectangle()
                    .cornerRadius(3)
                    .frame(width: 80, height: 6, alignment: .center)
                    .foregroundColor(.secondary)
                    .padding()
                
                
                ForEach(
                    store.appState.timelineData.getTimeline(timelineType: .session).status,
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
                
                DetailInfoView(status: status )
                    .padding(16)
                    .frame(height: 100)
                
                Composer(tweetTextBinding: $store.appState.setting.tweetInput.tweetText,
                         isProcessingDone: $store.appState.setting.isProcessingDone,
                         status: status)
                    .padding(.horizontal,16)
                    .frame(height: 42)
                    .background(Color.accentColor.opacity(0.4))
                
                RoundedCorners(color: Color.init("BackGround"), tl: 0, tr: 0, bl: 24, br: 24)
                    .frame(height: 64)
                    .foregroundColor(Color.init("BackGround"))
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
}

struct DetailViewSheet_Previews: PreviewProvider {
    static var previews: some View {
        DetailViewSheet(status: Status())
            .environmentObject(Store())
    }
}
