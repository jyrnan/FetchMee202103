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
    
    var body: some View {
        GeometryReader{proxy in
            ScrollView {
                Rectangle()
                    .cornerRadius(3)
                    .frame(width: 80, height: 6, alignment: .center)
                    .foregroundColor(.secondary)
                    .padding()
                
                VStack(spacing: 0){
                    ForEach(
                        store.appState.timelineData.getTimeline(timelineType: .session).status,
                        id: \.id) {status in
                        StatusRow(status: status, width: proxy.size.width)
                            .padding(.vertical, 0)
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
              
            }
        }
    }
}
#if Debug

struct DetailViewSheet_Previews: PreviewProvider {
    static var previews: some View {
        DetailViewSheet(status: Status.sample)
            .environmentObject(Store.sample)
    }
}
#endif
