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
    
    @State var user: JSON?
//    {UserRepository.shared.users[userIDString]}
    
    func userHandler(user: JSON) {
        self.user = user
    }
    
    
    init(userIDString: String, width:CGFloat = 64, height: CGFloat = 64) {
        
        self.userIDString  = userIDString
        self.width = width
        self.height = height
        
    }
    
    var body: some View {
            ZStack {
                NavigationLink(destination: UserViewRedux(userIDString: userIDString),
                               isActive: $presentedUserInfo, label:{EmptyView()} ).disabled(true)
                AvatarImageView(imageUrl: user?["profile_image_url_https"].string )
                        .frame(width: width, height: height, alignment: .center)
                        .onTapGesture(count: 2){
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            isShowAlert = true
                        }
                        .onTapGesture {
                            let user = UserInfo(id: userIDString)
                            store.dipatch(.userRequest(user: user, isLoginUser: false))
                            presentedUserInfo = true
                        }
                        .alert(isPresented: $isShowAlert, content: {
                            Alert(title: Text("没拍到"), message: Text("可能\(user?["name"].string ?? "该用户")不想让你拍"), dismissButton: .cancel(Text("下次吧")))
                        })
                ///显示头像补充图标
                ///如果该用户nickName不为空，则显示星标
                if checkFavoriteUser() {
                    FavoriteStarMarkView()
                }
            }.frame(width: width, height: height, alignment: .center)
            .onAppear{
                UserRepository.shared.getUser(userID: userIDString, compeletHandler: self.userHandler(user: ))
            }
    }
    
    func checkFavoriteUser() -> Bool {
        return twitterUsers.map{$0.userIDString}.contains(userIDString)
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
