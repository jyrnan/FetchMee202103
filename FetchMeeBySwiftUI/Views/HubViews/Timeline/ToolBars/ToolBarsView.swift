//
//  ToolBarsView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData

struct ToolBarsView: View {
    @EnvironmentObject var store: Store
    var user: UserInfo {let user = store.appState.setting.loginUser ?? UserInfo()
        return user
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetDraft.createdAt, ascending: true)]) var drafts: FetchedResults<TweetDraft>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Log.createdAt, ascending: true)]) var logs: FetchedResults<Log>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Status_CD.id_str, ascending: false),
                                    NSSortDescriptor(keyPath: \Status_CD.text, ascending: false)]) var statuses: FetchedResults<Status_CD>
   
    lazy var userPredicate: NSPredicate = NSPredicate(format: "%K == %@", #keyPath(Count.countToUser.userIDString), user.id)
    
    var statusOfLoginuser: Status_CD? {
        statuses.filter{$0.user?.userIDString == user.id}.first
    }
    var statusOfBookmarked: Status_CD? {
        statuses.filter{$0.user?.userIDString != user.id}.first
    }
    
    //控制三个toolBar正面朝向
    @State var toolBarIsFaceUp1: Bool = true
    @State var toolBarIsFaceUp2: Bool = true
    @State var toolBarIsFaceUp3: Bool = true
    
    var body: some View {
        VStack {
            HStack {
                Text("Tools").font(.caption).bold().foregroundColor(Color.gray)
                Spacer()
            }
            ToolBarView(isFaceUp: toolBarIsFaceUp1,
                        type: .friends,
                        label1Value: user.followed,
                        label2Value: user.following,
                        label3Value: user.lastDayAddedFollower)
                .onTapGesture {
                    if !toolBarIsFaceUp1 {
                        toolBarIsFaceUp1.toggle()
                    } else {
                        toolBarIsFaceUp1.toggle()
                        toolBarIsFaceUp2 = true
                        toolBarIsFaceUp3 = true
                    }
                }
            
            ToolBarView(isFaceUp: toolBarIsFaceUp2,type: .tweets,
                        label1Value: user.tweetsCount,
                        label2Value: user.tweetsCount,
                        label3Value: user.lastDayAddedTweets)
                .onTapGesture {
                    if !toolBarIsFaceUp2 {
                        toolBarIsFaceUp2.toggle()
                    } else {
                        toolBarIsFaceUp2.toggle()
                        toolBarIsFaceUp1 = true
                        toolBarIsFaceUp3 = true
                    }
                }
            
            ToolBarView(isFaceUp: toolBarIsFaceUp3, type: .tools,
                        label1Value: drafts.count,
                        label2Value: logs.count,
                        label3Value: logs.count)
                .onTapGesture {
                    if !toolBarIsFaceUp3 {
                        toolBarIsFaceUp3.toggle()
                    } else {
                        toolBarIsFaceUp3.toggle()
                        toolBarIsFaceUp1 = true
                        toolBarIsFaceUp2 = true
                    }
                }
            if statusOfLoginuser != nil {
                NavigationLink(destination: BookmarkedStatusView(userID: store.appState.setting.loginUser?.id),
                               label: {
                                StatusRow(status: statusOfLoginuser!)})
            }
            
            if statusOfBookmarked != nil {
                NavigationLink(destination: BookmarkedStatusView(),
                               label: {
                                StatusRow(status: statusOfBookmarked!)})
                
            }
        }
    }
}


extension ToolBarsView {
    mutating func calFollower() ->[Int] {
        var result: [Int] = [0, 0, 0]
        
        let fetchRequest: NSFetchRequest<Count> = Count.fetchRequest()
        fetchRequest.predicate = userPredicate
        do {
            let counts = try viewContext.fetch(fetchRequest)
            
            let lastDayCounts = counts.filter{count in
                return abs(count.createdAt?.timeIntervalSinceNow ?? 1000000 ) < 60 * 60 * 24}
            
            let lastDayMax = lastDayCounts.max {a, b in a.follower < b.follower}
            let lastDayMin = lastDayCounts.max {a, b in a.follower > b.follower}
            result[0] = Int((lastDayMax!.follower - lastDayMin!.follower))
            
        } catch let error as NSError {
            print("count not fetched \(error), \(error.userInfo)")
          }

        return result
    }
}
