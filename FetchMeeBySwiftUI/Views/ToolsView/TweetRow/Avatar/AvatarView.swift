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
    @EnvironmentObject var fetchMee: User
    @EnvironmentObject var downloader: Downloader
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TwitterUser.userIDString, ascending: true)]) var twitterUsers: FetchedResults<TwitterUser>
    
    @StateObject var avatarViewModel: AvatarViewModel
   
    @State var presentedUserInfo: Bool = false
    
    init(avatarViewModel: AvatarViewModel) {
        _avatarViewModel = StateObject(wrappedValue: avatarViewModel)
    }
    
    var body: some View {
        GeometryReader {geometry in
            ZStack {
                NavigationLink(destination: UserView(userIDString: avatarViewModel.userInfo.id),
                               isActive: $presentedUserInfo){
                    AvatarImageView(image: avatarViewModel.image)
                        .onTapGesture(count: 2){
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            avatarViewModel.tickle()
                        }
                        .onTapGesture(count: 1) {self.presentedUserInfo = true}
                        .alert(isPresented: $avatarViewModel.isShowAlert, content: {
                            Alert(title: Text("没拍到"), message: Text("可能\(avatarViewModel.userInfo.name ?? "该用户")不想让你拍"), dismissButton: .cancel(Text("下次吧")))
                        })
                }
                ///显示头像补充图标
                ///如果该用户nickName不为空，则显示星标
                if true {
                    FavoriteStarMarkView()
                }
            }
        }
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(avatarViewModel: AvatarViewModel(userInfo: UserInfo()))
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
