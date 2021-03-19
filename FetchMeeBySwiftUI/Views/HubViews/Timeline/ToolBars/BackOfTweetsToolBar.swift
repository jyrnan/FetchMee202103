//
//  BackOfTweetsToolBar.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/17.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine

struct BackOfTweetsToolBar: View {
    
    @EnvironmentObject var store: Store
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var counts: (followers: [Int], tweets: [Int]) = ([], [])
    
    var body: some View {
        VStack {
            HStack{
                CountDiagramView(type: .follower, counts: counts.followers.reversed())
                Spacer()
                CountDiagramView(type: .tweet, counts: counts.tweets.reversed())
            }
            .padding()
            .frame(height: 76)
            .background(Color.blue)
            .cornerRadius(16)
        }
        .onAppear{
            counts = Count.updateCount(for: store.appState.setting.loginUser ?? UserInfo())
        }
        
    }
}
struct BackOfTweetsToolBar_Previews: PreviewProvider {
    static var previews: some View {
        BackOfTweetsToolBar()
    }
}

