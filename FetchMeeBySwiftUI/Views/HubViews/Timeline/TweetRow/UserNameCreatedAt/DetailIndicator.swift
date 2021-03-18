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
    var tweetIDString: String
    
    var status: Status? {store.repository.status[tweetIDString]}
    
    var retweeted: Bool { status?.retweeted ?? false }
    var retweetedCount: Int {status?.retweet_count ?? 0 }
    
    var favorited: Bool { status?.favorited ?? false }
    var favoritedCount: Int {status?.favorite_count ?? 0 }
    
    var isMentioned: Bool  {store.repository.status[tweetIDString]?.in_reply_to_user_id_str == store.appState.setting.loginUser?.id}
    
    var body: some View {
        HStack(spacing: 0){
            Spacer()
            Circle()
                .fill(retweeted ? Color.green : Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 3)
            Circle()
                .fill(
                    favorited ? Color.red :
                        Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 3)
            Circle()
                .fill(isMentioned ? Color.accentColor : Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 3)

            Spacer()
        }
        .frame(width: 27, height: 11, alignment: .center)
        .opacity(0.7)
        .padding(.all, 0)
        .contentShape(Rectangle())
    }
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

struct DetailIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DetailIndicator(tweetIDString: "0000")
    }
}
