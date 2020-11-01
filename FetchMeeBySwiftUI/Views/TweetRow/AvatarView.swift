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
    @EnvironmentObject var fetchMee: AppData
    @EnvironmentObject var downloader: Downloader
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TwitterUser.userIDString, ascending: true)]) var twitterUsers: FetchedResults<TwitterUser>
    
    var avatar: UIImage?
    
    var userIDString: String?
    var userName: String? //传入用户的名字
    var screenName: String? //传入用户的名字
    var tweetIDString: String? //传入该头像所在的推文ID
    
    @State var isShowAlert: Bool = false //是否显示警告
    
    @State var presentedUserInfo: Bool = false
    @State var presentedUserImageGrabber: Bool = false
    var body: some View {
        GeometryReader {geometry in
        ZStack {
            ///切换到图片抓取页面
            NavigationLink(destination: ImageGrabView(userIDString: self.userIDString, userScreenName: self.screenName), isActive: $presentedUserImageGrabber){
                EmptyView()}

            AvatarImageView(image: avatar)
            .onTapGesture(count: 2, perform: {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                self.pat(text: "并缓缓举起了了大拇指")
            })
            .onTapGesture(count: 1) {self.presentedUserInfo = true}
            .sheet(isPresented: $presentedUserInfo) {UserInfo(userIDString: self.userIDString).environmentObject(self.alerts)
                .environmentObject(self.fetchMee).accentColor(self.fetchMee.setting.themeColor.color)}
            .simultaneousGesture(LongPressGesture().onEnded{_ in self.presentedUserImageGrabber = true})
            
            .alert(isPresented: self.$isShowAlert, content: {
                Alert(title: Text("没拍到"), message: Text("可能\(self.userName ?? "该用户")不想让你拍"), dismissButton: .cancel(Text("下次吧")))
            })
            
            ///显示头像补充图标
            ///如果该用户nickName不为空，则显示星标
            if twitterUsers.filter{$0.userIDString == userIDString}.first?.nickName != nil {
            Image(systemName: "star.circle.fill").foregroundColor(.accentColor)
                .scaledToFit()
                .frame(width: geometry.size.width * 0.18, height: geometry.size.height * 0.18, alignment: .center)
                .background(Color.white)
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
        let tweetText = "\(fetchMee.users[fetchMee.loginUserID]?.name ?? "楼主")拍了拍\"\(userName)\" \(text ?? "") \n@\(screenName)"
        swifter.postTweet(status: tweetText, inReplyToStatusID: self.tweetIDString, autoPopulateReplyMetadata: true, success: {_ in
            self.alerts.stripAlert.alertText = "Patting sent!"
            self.alerts.stripAlert.isPresentedAlert = true
        }, failure: {error in self.isShowAlert = true })
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(avatar: UIImage(systemName: "person.circle.fill"))
    }
}
