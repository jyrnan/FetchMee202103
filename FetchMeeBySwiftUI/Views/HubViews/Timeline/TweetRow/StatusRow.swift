//
//  StatusJsonRow.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/15.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import Kingfisher
import CoreData
import Swifter

struct StatusRow: View {
    enum RowType {
        case timeline
        case session
    }
    
    @EnvironmentObject var store: Store
 
    var status: Status
    ///约束图片的显示宽度，
    ///目前传入的宽度是屏幕宽度减去两侧空余
    var width: CGFloat
    
    var rowType: RowType = .timeline
    
    //avatar区域的宽度
    var avatarColumWidth: CGFloat = 80

    
    @State var isShowDetail: Bool = false
    
    init(status: Status, width: CGFloat) {
        self.status = status
        self.width = width
//        print("init of statusRow with id: \(status.id), name: \(status.user?.screenName)")
    }
    
    var avatar: some View {
        VStack(alignment: .leading){
            AvatarView(user: status.user!, width: 36, height: 36)
            Spacer()
        }
        .frame(width:store.appState.setting.userSetting?.uiStyle.avatarWidth )
    }
    
    var nameAndcreated: some View {
        HStack{ name; Spacer(); careated;  detailIndicator }
    }
    
    var name: some View {
        UserNameView(userName: status.user?.name ?? "Name",
                     screenName: status.user?.screenName ?? "screenName")
    }
    
    var detailIndicator: some View {
        ZStack{
            
            NavigationLink(destination: DetailViewRedux(status: status).environmentObject(store),
                           isActive:$isShowDetail ,
                           label:{EmptyView()} )
                .opacity(0.1)
                .disabled(true)
            
            DetailIndicator(status: status)
                .onTapGesture {
//                    isShowDetail = true
//                    store.dispatch(.fetchSession(tweetIDString: status.id))
                     }
            
        }.fixedSize()
    }
    
    var careated: some View {
        CreatedTimeView(created_at: status.createdAt )
    }
    
    var text: some View {
        Text(status.attributedString).multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    var retweeted: some View {
        Text("")
    }
    
    var body: some View {
        VStack(alignment: .leading){
            if status.retweeted_status_id_str == nil {
                HStack(alignment: .top) {
                avatar
                VStack(alignment: .leading){
                    nameAndcreated
                    text
                    
                    if status.quoted_status_id_str != nil {
                        QuotedStatusJsonRow(status: store.repository.getStatus(byID: status.quoted_status_id_str! ),
                                            width: width - 76)
                    }
                }
                
            }.padding()
            
                if let imageUrls = status.imageUrls {
                    ZStack{
                Images(imageUrlStrings: imageUrls)
                    .frame(width: width, height:width * 9 / 21 )
                    .clipped()
                        if status.mediaType == "video" || status.mediaType == "animated_gif" {
                            PlayButtonView(url: status.mediaUrlString!)
                        }
                    }
            }
            } else {
                RetweetMarkView(userIDString: status.id, userName: status.user?.name)
                    .padding(.top, 8).padding(.bottom, -16)
                StatusRow(status: store.repository.getStatus(byID: status.retweeted_status_id_str!), width: width)
            }
        }
        .background(status.in_reply_to_user_id_str == store.appState.setting.loginUser?.id ? Color.accentColor.opacity(0.15) : Color.clear)
//        .onTapGesture {
//            withAnimation{
//                store.dispatch(.selectTweetRow(tweetIDString: status.id))
//            }
//        }
    }
}

struct StatusRow_Previews: PreviewProvider {
    static var previews: some View {
        let status = Status(text: "人体对其所摄入的葡萄糖的处置调控能力称为「葡萄糖耐量」。正常人的糖调节机制完好，无论进食多少，血糖都能保持在一个比较稳定的范围内，即使一次性摄入大量的糖分", attributedString: JSON(dictionaryLiteral: ("text", "@人体 @对其所摄入 的葡萄糖的处置调控能力称为「葡萄糖耐量」。正常人的糖调节机制完好，无论进食多少，血糖都能保持在一个比较稳定的范围内，即使一次性摄入大量的糖分")).getAttributedString(),imageUrls: ["", "", "", ""])
        GeometryReader {proxy in
            VStack{
            StatusRow(status: Status(), width: proxy.size.width)
                .frame(width:proxy.size.width, height: 80, alignment: .center)
                .environmentObject(Store())
            StatusRow(status: status, width: proxy.size.width)
                .frame(width:proxy.size.width, height: 80, alignment: .center)
                .environmentObject(Store())
                .offset(CGSize(width: 0, height: 200))
                .accentColor(.blue)
            }
        }
    }
}
