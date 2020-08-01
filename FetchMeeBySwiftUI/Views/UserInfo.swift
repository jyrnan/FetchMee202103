//
//  UserInfo.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct UserInfo: View {
    var userIDString: String?
    @ObservedObject var user: User = User()
    
    var body: some View {
        Text(self.userIDString ?? "userIDString")
    }
}

struct UserInfo_Previews: PreviewProvider {
    static var previews: some View {
        UserInfo()
    }
}

