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
//    var tweetIDString: String
    
    var status: Status
//    {store.repository.statuses[tweetIDString]}
    
//    var retweeted: Bool { status?.retweeted ?? false }
//    var retweetedCount: Int {status?.retweet_count ?? 0 }
//
//    var favorited: Bool { status?.favorited ?? false }
//    var favoritedCount: Int {status?.favorite_count ?? 0 }
//
//    var isMentioned: Bool  {status?.isMentioned ?? false}
//    var isRead: Bool {status?.isRead ?? false}
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
                .fill( status.isRead ? Color.accentColor : Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 1)

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
        DetailIndicator(status: Status())
    }
}
