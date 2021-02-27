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
    var user: User {let user =  User()
        user.info = store.appState.setting.loginUser ?? UserInfo()
        return user
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetDraft.createdAt, ascending: true)]) var drafts: FetchedResults<TweetDraft>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Log.createdAt, ascending: true)]) var logs: FetchedResults<Log>
   
    lazy var userPredicate: NSPredicate = NSPredicate(format: "%K == %@", #keyPath(Count.countToUser.userIDString), user.info.id)
    
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
                        label1Value: user.info.followed,
                        label2Value: user.info.following,
                        label3Value: user.info.lastDayAddedFollower)
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
                        label1Value: user.info.tweetsCount,
                        label2Value: user.info.tweetsCount,
                        label3Value: user.info.lastDayAddedTweets)
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
        }
    }
}

struct ToolBarsView_Previews: PreviewProvider {
    static var previews: some View {
        ToolBarsView().environmentObject(User())
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
