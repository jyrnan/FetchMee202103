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
    
    var width: CGFloat
    
    var body: some View {
        if store.appState.timelineData.hubStatus.myLatestStatus != nil {

            NavigationLink(destination: BookmarkedStatusView(userID: store.appState.setting.loginUser?.id),
                           label: {
                StatusRow(status: store.appState.timelineData.hubStatus.myLatestStatus!.convertToStatus(), width: width - 2 * 16)
                    .background(Color.init("BackGroundLight"))
                    .cornerRadius(16)


            })

        }
        if store.appState.timelineData.hubStatus.bookmarkedStatus != nil {
            NavigationLink(destination: BookmarkedStatusView(),
                           label: {
                StatusRow(status: store.appState.timelineData.hubStatus.bookmarkedStatus!.convertToStatus(), width: width - 2 * 16)
                    .background(Color.init("BackGroundLight"))
                    .cornerRadius(16)
            })
        }


//        if store.appState.setting.loginUser?.tokenKey != nil
//            && store.appState.timelineData.hubStatus.myLatestDraft != nil {
//            Status_Draft(draft: store.appState.timelineData.hubStatus.myLatestDraft, width: width - 2 * 16)
//        }
//        Text("TODO")
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView(width: 300)
            .environmentObject(Store())
    }
}
