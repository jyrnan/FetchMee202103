//
//  StatusView.swift
//  FetchMee
//
//  Created by jyrnan on 2021/4/1.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI

struct StatusView: View {
    
    @EnvironmentObject var store: Store
    
    ///创建一个简单表示法
    var setting: UserSetting {store.appState.setting.loginUser?.setting ?? UserSetting()}
    
    var user: UserInfo {let user = store.appState.setting.loginUser ?? UserInfo()
        return user
    }
    
    var isLogined: Bool {store.appState.setting.loginUser?.tokenKey != nil}
    
    var width: CGFloat
    
    var body: some View {
        if store.appState.timelineData.hubStatus.myLatestStatus != nil {
            
            NavigationLink(destination: BookmarkedStatusView(userID: store.appState.setting.loginUser?.id),
                           label: {
                            Status_CDRow(status: store.appState.timelineData.hubStatus.myLatestStatus!, width: width - 2 * setting.uiStyle.insetH)
                            
                            
                           })
            
        }
        if store.appState.timelineData.hubStatus.bookmarkedStatus != nil {
            NavigationLink(destination: BookmarkedStatusView(),
                           label: {
                           
                            Status_CDRow(status: store.appState.timelineData.hubStatus.bookmarkedStatus!, width: width - 2 * setting.uiStyle.insetH)
                            })
        }
    
    
        if isLogined && store.appState.timelineData.hubStatus.myLatestDraft != nil {
        Status_Draft(draft: store.appState.timelineData.hubStatus.myLatestDraft, width: width - 2 * setting.uiStyle.insetH)
    }
//    else {
//        ForEach(drafts) {draft in
//            Status_Draft(draft: draft, width: width - 2 * setting.uiStyle.insetH)}
//    }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView(width: 300)
    }
}
