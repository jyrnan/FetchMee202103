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

struct QuotedStatusJsonRow: View {
    @EnvironmentObject var store: Store
    ///创建一个简单表示法
    var setting: UserSetting {store.appState.setting.loginUser?.setting ?? UserSetting()}
    
    var tweetID: String
    ///约束图片的显示宽度
    var width: CGFloat
    
    var status: JSON {store.repository.status[tweetID] ?? JSON.init("")}
    
//    var quotedStatusID: String? {status["quoted_status_id_str"].string }
    
    @State var isShowDetail: Bool = false
    
    var avatar: some View {
                   AvatarView(userIDString: status["user"]["id_str"].string ?? "", width: 18, height: 18)
    }
    
    var nameAndcreated: some View {
        HStack{avatar; name; careated; Spacer(); detailIndicator }
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
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0){
               
                VStack(alignment: .leading){
                    nameAndcreated
                    text.font(.callout)
                }
                .padding(4)
            if let imageUrls = getImagesUrls(status: status) {
                Images(imageUrlStrings: imageUrls)
                    .frame(width: width )
                    .clipped()
            }
        }
                .mask(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            
        
        
    }
    
    func getImagesUrls(status: JSON) -> [String]? {
        guard let medias = status["extended_entities"]["media"].array else {return nil}
        let imageUrls = medias.map{$0["media_url_https"].string!}
        return imageUrls
    }
    
}
