//
//  AvatarView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/31.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct AvatarView: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    
    var avatar: UIImage? = UIImage(systemName: "person.circle.fill")
    var userIDString: String?
    
    @State var presentedUserInfo: Bool = false
    
    var body: some View {
        Image(uiImage: self.avatar!)
            .resizable()
            .aspectRatio(contentMode: .fill)
//            .frame(width: 36, height: 36)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .onTapGesture {self.presentedUserInfo = true}
            .sheet(isPresented: $presentedUserInfo) {UserInfo(userIDString: self.userIDString).environmentObject(self.alerts)
                .environmentObject(self.user)
            }
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView()
    }
}
