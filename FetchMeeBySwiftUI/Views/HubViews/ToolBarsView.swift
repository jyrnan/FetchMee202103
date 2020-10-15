//
//  ToolBarsView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ToolBarsView: View {
    @EnvironmentObject var user: User
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetDraft.createdAt, ascending: true)]) var drafts: FetchedResults<TweetDraft>
    
    @State var toolBars: [ToolBarView] = []
    
    @State var toolBarIsFaceUp1: Bool = true
    @State var toolBarIsFaceUp2: Bool = true
    @State var toolBarIsFaceUp3: Bool = true
    
    var body: some View {
        VStack {
            HStack {
                Text("Tools").font(.caption).bold().foregroundColor(Color.gray)
                    .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                        addToolBarView(type: .tweets)
                    })
                Spacer()
            }
            ToolBarView(isFaceUp: toolBarIsFaceUp1,
                type: .friends,
                        label1Value: user.myInfo.followed,
                        label2Value: user.myInfo.following,
                        label3Value: 88)
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
                        label1Value: user.myInfo.tweetsCount,
                        label2Value: user.myInfo.tweetsCount,
                        label3Value: 88)
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
                        label1Value: user.myInfo.tweetsCount,
                        label2Value: user.myInfo.tweetsCount,
                        label3Value: drafts.count)
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
    func addToolBarView(type: ToolBarViewType) {
        switch type {
        case .friends:
            let toolBarView = ToolBarView(type: type,
                                          label1Value: user.myInfo.followed,
                                          label2Value: user.myInfo.following,
                                          label3Value: 88)
            self.toolBars.append(toolBarView)
            
        case .tweets:
            let toolBarView = ToolBarView(type: type,
                                          label1Value: user.myInfo.tweetsCount,
                                          label2Value: user.myInfo.tweetsCount,
                                          label3Value: 88)
            self.toolBars.append(toolBarView)
            
        case .tools:
            let toolBarView = ToolBarView(type: type,
                                          label1Value: user.myInfo.tweetsCount,
                                          label2Value: user.myInfo.tweetsCount,
                                          label3Value: 88)
            
            self.toolBars.append(toolBarView)
            
        }
    }
}
