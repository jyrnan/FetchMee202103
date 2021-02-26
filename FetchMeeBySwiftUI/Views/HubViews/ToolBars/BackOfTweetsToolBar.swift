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
    
    var body: some View {
        VStack {
            HStack{
                CountDiagramView(userInfo: store.appState.setting.loginUser!, context: viewContext)
            }
        }
        .padding([.leading, .trailing], 12)
    }
}
struct BackOfTweetsToolBar_Previews: PreviewProvider {
    static var previews: some View {
        BackOfTweetsToolBar()
    }
}

