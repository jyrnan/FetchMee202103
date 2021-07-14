//
//  DetailIndicator.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/19.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter

struct DetailIndicator: View {
    @EnvironmentObject var store: Store
    
    var status: Status

    var body: some View {
        HStack(spacing: 0){
            Spacer()
            Circle()
                .fill(status.retweeted ? Color.green : Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 1)
            Circle()
                .fill(
                    status.favorited ? Color.red :
                        Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 1)
            Circle()
                .fill(isReplyToMe() ? Color.accentColor : Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 1)

            Spacer()
        }
        .frame(width: 27, height: 11, alignment: .center)
        .opacity(0.7)
        .padding(.all, 0)
        .contentShape(Rectangle())
    }
    
    private func isReplyToMe() -> Bool {
        return status.in_reply_to_user_id_str == store.appState.setting.loginUser?.id
    }
   
}
#if Debug

struct DetailIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DetailIndicator(status: Status.sample)
            .environmentObject(Store.sample)
    }
}
#endif
