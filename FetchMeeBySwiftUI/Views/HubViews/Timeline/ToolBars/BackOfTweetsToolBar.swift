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
                CountDiagramView(type: .follower)
                Spacer()
                CountDiagramView(type: .tweet)
            }
            .padding()
            .frame(height: 76)
            .background(Color.blue)
            .cornerRadius(16)
        }
        
    }
}
struct BackOfTweetsToolBar_Previews: PreviewProvider {
    static var previews: some View {
        BackOfTweetsToolBar()
    }
}

