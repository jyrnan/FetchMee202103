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
    
    ///创建一个简单表示法
    var setting: UserSetting {store.appState.setting.loginUser?.setting ?? UserSetting()}
    
    var user: UserInfo {let user = store.appState.setting.loginUser ?? UserInfo()
        return user
    }
    
    var isLogined: Bool {store.appState.setting.loginUser?.tokenKey != nil}
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetDraft.createdAt, ascending: false)]) var drafts: FetchedResults<TweetDraft>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Log.createdAt, ascending: true)]) var logs: FetchedResults<Log>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Status_CD.id_str, ascending: false),
                                    NSSortDescriptor(keyPath: \Status_CD.created_at, ascending: false)])
    var statuses: FetchedResults<Status_CD>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Status_CD.id_str, ascending: false),
                                     NSSortDescriptor(keyPath: \Status_CD.created_at, ascending: false)],
    predicate: NSPredicate(format: "%K == %d", #keyPath(Status_CD.isBookmarked), true)
    ) var bookmarkedStatuses: FetchedResults<Status_CD>
    
    
    lazy var userPredicate: NSPredicate = NSPredicate(format: "%K == %@", #keyPath(Count.countToUser.userIDString), user.id)
    
    var statusOfLoginuser: Status_CD? {
        statuses.filter{$0.user?.userIDString == user.id}.first
    }
    var statusOfBookmarked: Status_CD? {
        statuses.filter{$0.isBookmarked == true}.first
    }
    var statusOfDraft: TweetDraft? {
        drafts.first
    }
    
    //控制三个toolBar正面朝向
    @State var toolBarIsFaceUp1: Bool = true
    @State var toolBarIsFaceUp2: Bool = true
    @State var toolBarIsFaceUp3: Bool = true
    
    var width: CGFloat
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Tools").font(.caption).bold().foregroundColor(Color.gray)
                Spacer()
            }
            
            if isLogined {
                
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
                                    Status_CDRow(status: statusOfLoginuser!, width: width - 2 * setting.uiStyle.insetH)
                                    
                                    
                                   })
                    
                }
                if !bookmarkedStatuses.isEmpty {
                    NavigationLink(destination: BookmarkedStatusView(),
                                   label: {
                                   
                                    Status_CDRow(status: bookmarkedStatuses.first!, width: width - 2 * setting.uiStyle.insetH)
                                    })
                }
            }
            
            if isLogined && drafts.first != nil {
                Status_Draft(draft: drafts.first, width: width - 2 * setting.uiStyle.insetH)
            }
            else {
                ForEach(drafts) {draft in
                    Status_Draft(draft: draft, width: width - 2 * setting.uiStyle.insetH)}
            }
            
        }
        
    }
}

