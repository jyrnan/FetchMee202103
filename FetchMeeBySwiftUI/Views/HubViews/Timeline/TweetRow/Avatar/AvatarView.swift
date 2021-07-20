//
//  AvatarView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/31.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData
import Swifter

struct AvatarView: View {
    @EnvironmentObject var store: Store
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \UserCD.userIDString, ascending: true)]) var userCDs: FetchedResults<UserCD>
    
    @State var presentedUserInfo: Bool = false
    
    var user: User
    var width: CGFloat = 64
    var height: CGFloat = 64
    
    var body: some View {
        ZStack {
            AvatarImageView(imageUrl: user.avatarUrlString, hasNickname: user.nickName != nil)
            
                .frame(width: width, height: height, alignment: .center)
                .onTapGesture(count: 2){
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    store.appState.timelineData.users[user.idString]?.isFavoriteUser.toggle()
                    store.dispatch(.update)
                    store.dispatch(.hubStatusRequest)
                }
                .onTapGesture {
                    presentedUserInfo = true
                    store.dispatch(.fetchTimeline(timelineType: .user(userID: user.idString), mode: .top))
                }
            
            ///显示头像补充图标
            ///如果该用户nickName不为空，则显示星标
            if user.isLoginUser == true || user.isFavoriteUser == true {
                FavoriteStarMarkView(user: user)
            }
        }
        .frame(width: width, height: height, alignment: .center)
        .sheet(isPresented: $presentedUserInfo, onDismiss: {}) {
            UserView(user: user)
                    .accentColor(store.appState.setting.userSetting?.themeColor.color)
        }
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(user: User(isFavoriteUser: true))
    }
}


