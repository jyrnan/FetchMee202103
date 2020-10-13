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
    @State var toolBars: [ToolBarView] = []
    
    var body: some View {
        VStack {
            HStack {
                Text("Tools").font(.caption).bold().foregroundColor(Color.gray)
                    .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                        addToolBarView(type: .tweets)
                    })
                Spacer()
            }
            ToolBarView(type: .friends,
                        label1Value: user.myInfo.followed,
                        label2Value: user.myInfo.following,
                        label3Value: 88)
            ToolBarView(type: .tweets,
                        label1Value: user.myInfo.tweetsCount,
                        label2Value: user.myInfo.tweetsCount,
                        label3Value: 88)
            ToolBarView(type: .tools,
                        label1Value: user.myInfo.tweetsCount,
                        label2Value: user.myInfo.tweetsCount,
                        label3Value: 88)
            
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
