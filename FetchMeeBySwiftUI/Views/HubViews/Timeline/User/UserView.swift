//
//  UserView.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/27.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation

import SwiftUI
import CoreData
import Swifter

struct UserView: View {
    @EnvironmentObject var store: Store
     
    var user: User
    var body: some View {
        
        GeometryReader{proxy in
            
            ScrollView {
                
                UserInfo(user: user, width: proxy.size.width)
                
                UserTimeline(userIDString: user.id, width: proxy.size.width)

            }.listStyle(.plain)
        }
        
//        .navigationTitle(user.name)
    }
}

