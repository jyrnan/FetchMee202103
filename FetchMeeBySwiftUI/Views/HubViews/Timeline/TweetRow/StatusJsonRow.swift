//
//  StatusJsonRow.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/15.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import KingfisherSwiftUI
import CoreData
import Swifter

struct StatusJsonRow: View {
    @EnvironmentObject var store: Store
    ///创建一个简单表示法
    var setting: UserSetting {store.appState.setting.loginUser?.setting ?? UserSetting()}
    
    var tweetID: String
    ///约束图片的显示宽度
    var width: CGFloat
    
    var status: JSON {store.repository.status[tweetID] ?? JSON.init("")}
    
    var quotedStatusID: String? {status["quoted_status_id_str"].string }
    var retweetStatusID: String? {status["retweeted_status"]["id_str"].string}
    
    @State var isShowDetail: Bool = false
    
    var avatar: some View {
        VStack(alignment: .leading){
            AvatarView(userIDString: status["user"]["id_str"].string ?? "", width: 36, height: 36)
            Spacer()
        }
        .frame(width:setting.uiStyle.avatarWidth )
    }
    
    var nameAndcreated: some View {
        HStack{ name; careated; Spacer(); detailIndicator }
    }
    
    var name: some View {
        UserNameView(userName: status["user"]["name"].string ?? "Name",
                     screenName: status["user"]["screen_name"].string ?? "screenName")
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
        CreatedTimeView(createdTime: status["created_at"].string ?? "now")
    }
    
    var text: some View {
        Text(status["text"].string ?? "Text")
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
            
            if let imageUrls = getImagesUrls(status: status) {
                Images(imageUrlStrings: imageUrls)
                    .frame(width: width )
                    
                    .clipped()
            }
            } else {
                RetweetMarkView(userIDString: tweetID, userName: status["user"]["name"].string)
                    .padding(.top, 8).padding(.bottom, -16)
                StatusJsonRow(tweetID: retweetStatusID!, width: width)
            }
        }
        .onTapGesture {
            withAnimation{
                store.dipatch(.selectTweetRow(tweetIDString: tweetID))
            }
        }
    }
    
    func getImagesUrls(status: JSON) -> [String]? {
        guard let medias = status["extended_entities"]["media"].array else {return nil}
        let imageUrls = medias.map{$0["media_url_https"].string!}
        return imageUrls
    }
    
}
