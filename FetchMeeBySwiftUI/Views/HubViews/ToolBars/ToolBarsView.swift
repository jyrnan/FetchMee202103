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
    var user: User
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetDraft.createdAt, ascending: false)]) var drafts: FetchedResults<TweetDraft>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Log.createdAt, ascending: true)]) var logs: FetchedResults<Log>
    lazy var userPredicate: NSPredicate = NSPredicate(format: "%K == %@", #keyPath(Count.countToUser.userIDString), user.id)
    
    //控制三个toolBar正面朝向
    @State var toolBarIsFaceUp1: Bool = true
    @State var toolBarIsFaceUp2: Bool = true
    @State var toolBarIsFaceUp3: Bool = true
    
    //    var width: CGFloat
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Status").font(.caption).bold().foregroundColor(Color.gray)
                Spacer()
            }
            ToolBarView(isFaceUp: toolBarIsFaceUp1,
                        type: .friends,
                        label1Value: user.followed,
                        label2Value: user.following,
                        label3Value: user.followersAddedOnLastDay)
                .onTapGesture {
                    withAnimation{
                        if !toolBarIsFaceUp1 {
                            toolBarIsFaceUp1.toggle()
                        } else {
                            toolBarIsFaceUp1.toggle()
                            toolBarIsFaceUp2 = true
                            toolBarIsFaceUp3 = true
                        }
                    }
                }
            
            ToolBarView(isFaceUp: toolBarIsFaceUp2,type: .tweets,
                        label1Value: user.tweets,
                        label2Value: user.tweets,
                        label3Value: user.tweetsPostedOnLastDay)
                .onTapGesture {
                    withAnimation{
                        if !toolBarIsFaceUp2 {
                            toolBarIsFaceUp2.toggle()
                        } else {
                            toolBarIsFaceUp2.toggle()
                            toolBarIsFaceUp1 = true
                            toolBarIsFaceUp3 = true
                        }
                    }
                }
            
            ToolBarView(isFaceUp: toolBarIsFaceUp3, type: .tools,
                        label1Value: drafts.count,
                        label2Value: logs.count,
                        label3Value: logs.count)
                .onTapGesture {
                    withAnimation{
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
}


struct ToolBarsView_Previews: PreviewProvider {
    static var previews: some View {
        ToolBarsView( user: User())
    }
}
