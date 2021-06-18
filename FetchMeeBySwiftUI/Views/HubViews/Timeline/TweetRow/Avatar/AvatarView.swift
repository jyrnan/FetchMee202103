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
import Kingfisher

struct AvatarView: View {
    @EnvironmentObject var store: Store
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \UserCD.userIDString, ascending: true)]) var userCDs: FetchedResults<UserCD>
    
    @State var presentedUserInfo: Bool = false
    
    var userIDString: String
    
    var width: CGFloat
    var height: CGFloat
    
    var user: User?
    
    init(userIDString: String = "", width:CGFloat = 64, height: CGFloat = 64, user: User? = User()) {
        
        self.userIDString  = userIDString
        self.width = width
        self.height = height
        self.user = user
    }
    
    var body: some View {
        ZStack {
                            NavigationLink(destination: UserView(user: user ?? User()),
                                           isActive: $presentedUserInfo,
                                           label:{EmptyView()} ).disabled(true)
            AvatarImageView(imageUrl: user?.avatarUrlString)
                .frame(width: width, height: height, alignment: .center)
                .onTapGesture(count: 2){
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    store.repository.users[userIDString]?.isFavoriteUser.toggle()
                    store.dispatch(.update)
                    store.dispatch(.hubStatusRequest)
                }
                .onTapGesture {
                    presentedUserInfo = true
                    store.dispatch(.fetchTimeline(timelineType: .user(userID: user?.idString ?? "0000"), mode: .top))
                }
            
            ///显示头像补充图标
            ///如果该用户nickName不为空，则显示星标
            if user?.isLoginUser == true || user?.isFavoriteUser == true {
                FavoriteStarMarkView(user: user!)
            }
        }
        .frame(width: width, height: height, alignment: .center)
    }
}

struct AvatarView_Previews: PreviewProvider {
//    static let store = Store()
    static var previews: some View {
        AvatarView(userIDString: "")
//            .environmentObject(store)
    }
}


