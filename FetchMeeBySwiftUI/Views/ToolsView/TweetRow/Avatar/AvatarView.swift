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
    
    var avatar: UIImage?
    
    var avatarUrlString: String
    @StateObject var avatarImage: RemoteImageFromUrl
    
    var userIDString: String?
    var userName: String? //传入用户的名字
    var screenName: String? //传入用户的名字
    var tweetIDString: String? //传入该头像所在的推文ID
    
    @State var isShowAlert: Bool = false //是否显示警告
    @State var presentedUserInfo: Bool = false
    
    init(avatar: UIImage?, avatarUrlString: String, userIDString: String? = nil, userName: String? = nil, screenName: String? = nil, tweetIDString: String? = nil) {
        self.avatar = avatar
        self.avatarUrlString = avatarUrlString
        self.userIDString = userIDString
        self.screenName = screenName
        self.tweetIDString = tweetIDString
        
        _avatarImage = StateObject(wrappedValue: RemoteImageFromUrl(imageUrl: avatarUrlString, imageType: .original))
    }
    
    var body: some View {
        GeometryReader {geometry in
        ZStack {
            NavigationLink(destination: UserView(userIDString: self.userIDString, userScreenName: screenName),
                           isActive: $presentedUserInfo){
                AvatarImageView(image: avatarImage.image)
            .onTapGesture(count: 2, perform: {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                self.pat(text: "并缓缓举起了了大拇指")
            })
            .onTapGesture(count: 1) {
                self.presentedUserInfo = true            }
            .alert(isPresented: self.$isShowAlert, content: {
                Alert(title: Text("没拍到"), message: Text("可能\(self.userName ?? "该用户")不想让你拍"), dismissButton: .cancel(Text("下次吧")))
            })
            }
            ///显示头像补充图标
            ///如果该用户nickName不为空，则显示星标
            if twitterUsers.filter{$0.userIDString == userIDString}.first?.nickName != nil {
            Image(systemName: "star.circle.fill").foregroundColor(.accentColor)
                .scaledToFit().background(Circle().foregroundColor(.white).scaleEffect(0.9))
                .frame(width: geometry.size.width * 0.18, height: geometry.size.height * 0.18, alignment: .center)
                .offset(x: geometry.size.width * 0.33, y: geometry.size.height * 0.33)
            }
        }
        }
    }
    
    
    /// 拍一拍的实现方法
    /// TODO：自定义动作类型
    /// - Parameter text: 输入的文字
    func pat(text: String? = "") {
        guard let userName = self.userName else { return}
        guard let screenName = self.screenName else { return}
        let tweetText = "\(fetchMee.info.name ?? "楼主")拍了拍\"\(userName)\" \(text ?? "") \n@\(screenName)"
        swifter.postTweet(status: tweetText, inReplyToStatusID: self.tweetIDString, autoPopulateReplyMetadata: true, success: {_ in
            self.alerts.stripAlert.alertText = "Patting sent!"
            self.alerts.stripAlert.isPresentedAlert = true
        }, failure: {error in self.isShowAlert = true })
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(avatar: UIImage(systemName: "person.circle.fill"), avatarUrlString: "")
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
