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
    ///创建一个简单表示法
    var setting: UserSetting {store.appState.setting.loginUser?.setting ?? UserSetting()}
    
    var tweetID: String
    
    ///约束图片的显示宽度，
    ///目前传入的宽度是屏幕宽度减去两侧空余
    var width: CGFloat
    
    var rowType: RowType = .timeline
    
    //avatar区域的宽度
    var avatarColumWidth: CGFloat = 80
    
    var status: Status {store.repository.getStatus(byID: tweetID)}
    
    var quotedStatusID: String? {status.quoted_status_id_str }
    var retweetStatusID: String? {status.retweeted_status_id_str}
    
    @State var isShowDetail: Bool = false
    
    var avatar: some View {
        VStack(alignment: .leading){
            AvatarView(userIDString: status.user?.id ?? "", width: 36, height: 36)
            Spacer()
        }
        .frame(width:setting.uiStyle.avatarWidth )
    }
    
    var nameAndcreated: some View {
        HStack{ name; careated; Spacer(); detailIndicator }
    }
    
    var name: some View {
        UserNameView(userName: status.user?.name ?? "Name",
                     screenName: status.user?.screenName ?? "screenName")
    }
    
    var detailIndicator: some View {
        ZStack{
            
            NavigationLink(destination: DetailViewRedux(tweetIDString: tweetID), isActive:$isShowDetail , label:{EmptyView()} ).opacity(0.1).disabled(true)
            DetailIndicator(tweetIDString: tweetID)
                .onTapGesture {
                    store.dipatch(.fetchSession(tweetIDString: tweetID))
                    isShowDetail = true }
            
        }.fixedSize()
    }
    
    var careated: some View {
        CreatedTimeView(created_at: status.createdAt ?? Date())
    }
    
    var text: some View {
        return { () -> AnyView in
            switch rowType {
            case .timeline: return AnyView(Text(status.text ?? "Text").fixedSize(horizontal: false, vertical: true))
            case .session: return  AnyView(NSAttributedStringView(attributedText: status.attributedText!, width: width - avatarColumWidth))
            }
        }()
      }
    
    var retweeted: some View {
        Text("")
    }
    
    var body: some View {
        VStack(alignment: .leading){
            if retweetStatusID == nil {
                HStack(alignment: .top) {
                avatar
                VStack(alignment: .leading){
                    nameAndcreated
                    text
                    
                    if quotedStatusID != nil {
                       QuotedStatusJsonRow(tweetID: quotedStatusID!, width: width - 76)
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
                RetweetMarkView(userIDString: tweetID, userName: status.user?.name)
                    .padding(.top, 8).padding(.bottom, -16)
                StatusRow(tweetID: retweetStatusID!, width: width)
            }
        }
        .background(status.in_reply_to_user_id_str == store.appState.setting.loginUser?.id ? Color.accentColor.opacity(0.15) : Color.clear)
        .onTapGesture {
            withAnimation{
                store.dipatch(.selectTweetRow(tweetIDString: tweetID))
            }
        }
    }
}
