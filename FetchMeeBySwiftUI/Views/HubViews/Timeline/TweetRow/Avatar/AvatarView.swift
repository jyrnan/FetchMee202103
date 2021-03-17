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
import KingfisherSwiftUI

struct AvatarView: View {
    @EnvironmentObject var store: Store
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TwitterUser.userIDString, ascending: true)]) var twitterUsers: FetchedResults<TwitterUser>
    
    @State var presentedUserInfo: Bool = false
    @State var isShowAlert: Bool = false
    
    var userIDString: String
    
    var width: CGFloat
    var height: CGFloat
    
    var user: UserInfo? {store.repository.users[userIDString]}
    
    
    
    var imageUrl:String? {user?.avatarUrlString ?? twitterUsers.filter{$0.userIDString == userIDString}.first?.avatar}
    
    init(userIDString: String, width:CGFloat = 64, height: CGFloat = 64) {

        self.userIDString  = userIDString
        self.width = width
        self.height = height
        }
    
    var body: some View {
            ZStack {
                NavigationLink(destination: UserViewRedux(userIDString: userIDString),
                               isActive: $presentedUserInfo, label:{EmptyView()} ).disabled(true)
                AvatarImageView(imageUrl: imageUrl )
                        .frame(width: width, height: height, alignment: .center)
                        .onTapGesture(count: 2){
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            isShowAlert = true
                        }
                        .onTapGesture {
                            presentedUserInfo = true
                        }
                        .alert(isPresented: $isShowAlert, content: {
                            Alert(title: Text("没拍到"), message: Text("可能\(user?.name ?? "该用户")不想让你拍"), dismissButton: .cancel(Text("下次吧")))
                        })
                ///显示头像补充图标
                ///如果该用户nickName不为空，则显示星标
                if checkMarkedUser() {
                    FavoriteStarMarkView(isFavoriteUser: checkFavoriteUser())
                }
            }.frame(width: width, height: height, alignment: .center)
               }
    func checkMarkedUser() -> Bool {
        return twitterUsers.map{$0.userIDString}.contains(userIDString)
    }
    
    func checkFavoriteUser() -> Bool {
        return twitterUsers.filter{$0.userIDString == userIDString}.first?.nickName != nil
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(userIDString: "")
    }
}

extension AvatarView {
    func configureBackground() {
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = UIColor.red
        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
        print(#line, "NavigationBar changed.")
    }
}
