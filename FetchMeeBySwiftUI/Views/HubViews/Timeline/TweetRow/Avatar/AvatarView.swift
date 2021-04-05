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
    @State var isShowAlert: Bool = false
    
    var userIDString: String
    
    var width: CGFloat
    var height: CGFloat
    
    var user: User? {store.repository.users[userIDString]}
    @State var requestUser = User()
    
    var imageUrl:String? {user?.avatarUrlString ?? userCDs.filter{$0.userIDString == userIDString}.first?.avatarUrlString}
    
    init(userIDString: String, width:CGFloat = 64, height: CGFloat = 64) {

        self.userIDString  = userIDString
        self.width = width
        self.height = height
        }
    
    var body: some View {
            ZStack {
                NavigationLink(destination: UserView(user: requestUser),
                               isActive: $presentedUserInfo, label:{EmptyView()} ).disabled(true)
                AvatarImageView(imageUrl: imageUrl )
                        .frame(width: width, height: height, alignment: .center)
                        .onTapGesture(count: 2){
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            store.repository.users[userIDString]?.isFavoriteUser.toggle()
                            store.dipatch(.update)
                            store.dipatch(.hubStatusRequest)
                        }
                        .onTapGesture {
                            if let user = store.repository.users[userIDString] {
                                requestUser = user
                                print(#line, #file, user.bannerUrlString)
                                presentedUserInfo = true
                                   
                            store.dipatch(.fetchTimeline(timelineType: .user(userID: userIDString), mode: .top))
                                    
                            }
                            
                        }
                        .alert(isPresented: $isShowAlert, content: {
                            Alert(title: Text("没拍到"), message: Text("可能\(user?.name ?? "该用户")不想让你拍"), dismissButton: .cancel(Text("下次吧")))
                        })
//                    .sheet(isPresented: $presentedUserInfo, content: {UserView(user: requestUser)
//                        .environmentObject(store)
//                        .environment(\.managedObjectContext, viewContext)
//                    })
                ///显示头像补充图标
                ///如果该用户nickName不为空，则显示星标
                if user?.isLoginUser == true || user?.isFavoriteUser == true {
                    FavoriteStarMarkView(user: user!)
                }
            }.frame(width: width, height: height, alignment: .center)
               }
    func checkMarkedUser() -> Bool {
        return userCDs.map{$0.userIDString}.contains(userIDString)
    }
    
    func checkFavoriteUser() -> Bool {
        return userCDs.filter{$0.userIDString == userIDString}.first?.nickName != nil
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
