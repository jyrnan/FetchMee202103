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
    @EnvironmentObject var downloader: Downloader
    
    var avatar: UIImage?
    
    var userIDString: String?
    var userName: String? //传入用户的名字
    var screenName: String? //传入用户的名字
    var tweetIDString: String? //传入该头像所在的推文ID
    
    @State var isShowAlert: Bool = false //是否显示警告
    
    @State var presentedUserInfo: Bool = false
    @State var presentedUserImageGrabber: Bool = false
    var body: some View {
        ZStack {
            EmptyView()
                .sheet(isPresented: $presentedUserImageGrabber) {ImageGrabView(userIDString: self.userIDString, userScreenName: self.screenName).environmentObject(self.alerts)
                    .environmentObject(self.user).accentColor(self.user.myInfo.setting.themeColor.color).environmentObject(downloader)
                }
            AvatarImageView(image: avatar)
            .onTapGesture(count: 2, perform: {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                print(#line, "pai yi pai")
                self.pat()
            })
            
            .onTapGesture(count: 1) {self.presentedUserInfo = true}
            .sheet(isPresented: $presentedUserInfo) {UserInfo(userIDString: self.userIDString).environmentObject(self.alerts)
                .environmentObject(self.user).accentColor(self.user.myInfo.setting.themeColor.color)
            }
            .simultaneousGesture(LongPressGesture()
                                    .onEnded{_ in
                                        print(#line, "long press")
                                        self.presentedUserImageGrabber = true
                                    })
            
            .alert(isPresented: self.$isShowAlert, content: {
                Alert(title: Text("没拍到"), message: Text("可能\(self.userName ?? "该用户")不想让你拍"), dismissButton: .cancel(Text("下次吧")))
            })
            
        }
    }
    
    func pat() {
        guard let userName = self.userName else { return}
        guard let screenName = self.screenName else { return}
        let tweetText = "\(self.user.myInfo.name ?? "楼主")拍了拍\"\(userName)\" \n@\(screenName)"
        swifter.postTweet(status: tweetText, inReplyToStatusID: self.tweetIDString, autoPopulateReplyMetadata: true, success: {_ in
            self.alerts.stripAlert.alertText = "Patting sent!"
            self.alerts.stripAlert.isPresentedAlert = true
        }, failure: {error in
            self.isShowAlert = true
        }     )
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(avatar: UIImage(systemName: "person.circle.fill"))
    }
}
