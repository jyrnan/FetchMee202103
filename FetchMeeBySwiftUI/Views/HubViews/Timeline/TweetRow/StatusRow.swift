//
//  StatusJsonRow.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/15.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
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
    
    var avatar: some View {
        VStack(alignment: .leading){
            AvatarView(user: store.appState.timelineData.users[status.user?.idString ?? "0000"] ?? User(),
                       width: 36, height: 36)
            Spacer()
        }
        .frame(width:store.appState.setting.userSetting?.uiStyle.avatarWidth )
    }
    
    var nameAndcreated: some View {
        HStack{ name; Spacer(); careated;  detailIndicator }
    }
    
    var name: some View {
        UserNameView(userName: status.user?.name ?? "Unknow",
                     screenName: status.user?.screenName ?? "Unkown")
    }
    
    var detailIndicator: some View {
        ZStack{
                DetailIndicator(status: status)
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
                        QuotedStatusJsonRow(status: store.appState.timelineData.getStatus(byID: status.quoted_status_id_str! ),
                                            width: width - 76)
                    }
                }
                
            }.padding()
            
                if let imageUrls = status.imageUrls {
                    ZStack{
                Images(imageUrlStrings: imageUrls)
                            .frame(width: width, height:width * 9 / 21)
                    .clipped()
                        if status.mediaType == "video" || status.mediaType == "animated_gif" {
                            PlayButtonView(url: status.mediaUrlString!)
                        }
                    }
            }
            } else {
                RetweetMarkView(userIDString: status.id, userName: status.user?.name).frame(width: width - 30)
                    .padding(.top, 8).padding(.bottom, -16)
                StatusRow(status: store.appState.timelineData.statuses[status.retweeted_status_id_str!] ??  Status(), width: width)
            }
        }
        .background(status.in_reply_to_user_id_str == store.appState.setting.loginUser?.id ? Color.accentColor.opacity(0.15) : Color.clear)
        .contextMenu(menuItems: {
            StatusContextMenu(store: store, status: status)
        })
        
    }
}


struct StatusRow_Previews: PreviewProvider {
    static var previews: some View {
        
        GeometryReader {proxy in
            VStack{
            StatusRow(status: Status(), width: proxy.size.width)
                .frame(width:proxy.size.width, height: 80, alignment: .center)
                .environmentObject(Store())
                StatusRow(status: Status.sample, width: proxy.size.width)
                .frame(width:proxy.size.width, height: 80, alignment: .center)
                .environmentObject(Store())
                .offset(CGSize(width: 0, height: 200))
                .accentColor(.blue)
            }
        }
        .environmentObject(Store.sample)
    }
}

