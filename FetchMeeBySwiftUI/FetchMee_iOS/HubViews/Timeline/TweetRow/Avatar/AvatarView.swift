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
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var fetchMee: User
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TwitterUser.userIDString, ascending: true)]) var twitterUsers: FetchedResults<TwitterUser>
    
    
    @ObservedObject var viewModel: AvatarViewModel
   
    @State var presentedUserInfo: Bool = false
    
    var width: CGFloat
    var height: CGFloat
    
    init(viewModel: AvatarViewModel, width:CGFloat = 64, height: CGFloat = 64) {
        self.viewModel = viewModel
        
        self.width = width
        self.height = height
    }
    
    var body: some View {
//        GeometryReader {geometry in
            ZStack {
                NavigationLink(destination: UserView(userIDString: viewModel.userIDString ?? "0000"),
                               isActive: $presentedUserInfo, label:{EmptyView()} ).disabled(true)
                    AvatarImageView(image: viewModel.image)
                        .frame(width: width, height: height, alignment: .center)
                        .onTapGesture(count: 2){
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            viewModel.tickle()
                        }
                        .onTapGesture {
                            presentedUserInfo = true
                        }
                        .alert(isPresented: $viewModel.isShowAlert, content: {
                            Alert(title: Text("没拍到"), message: Text("可能\(viewModel.userName ?? "该用户")不想让你拍"), dismissButton: .cancel(Text("下次吧")))
                        })
//                }
                ///显示头像补充图标
                ///如果该用户nickName不为空，则显示星标
                if checkFavoriteUser() {
                    FavoriteStarMarkView()
                }
            }.frame(width: width, height: height, alignment: .center)
//        }
    }
    
    func checkFavoriteUser() -> Bool {
        return twitterUsers.map{$0.userIDString}.contains(viewModel.userIDString)
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(viewModel: AvatarViewModel(user: JSON.init("")))
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
