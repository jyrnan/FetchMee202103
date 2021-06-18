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
import Kingfisher
import Swifter

struct UserView: View {
    @EnvironmentObject var store: Store
 
//    var userIDString: String //传入需查看的用户信息的ID
    
    var user: User
    var body: some View {
        
        GeometryReader{proxy in
            
            List {
                
                UserInfo(user: user, width: proxy.size.width)
                
                UserTimeline(userIDString: user.id, width: proxy.size.width)

            }.listStyle(.plain)
        }
        
        .navigationTitle(user.name)
    }
}

