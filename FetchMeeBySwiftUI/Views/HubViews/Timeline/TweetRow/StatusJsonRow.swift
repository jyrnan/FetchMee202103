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
    
    var tweetID: String
    ///约束图片的显示宽度
    var width: CGFloat
    
    
    var status: JSON {StatusRepository.shared.status[tweetID] ?? JSON.init("")}
    @State var isShowDetail: Bool = false
    var avatar: some View {
        VStack(alignment: .leading){
            AvatarView(userIDString: status["user"]["id_str"].string ?? "", width: 36, height: 36)
            Spacer()
        }
    }
    
    var nameAndcreated: some View {
        HStack{
        UserNameView(userName: status["user"]["name"].string ?? "Name",
                     screenName: status["user"]["screen_name"].string ?? "screenName")
            CreatedTimeView(createdTime: status["created_at"].string ?? "now")
            Spacer()
            ZStack{
                
                NavigationLink(destination: DetailViewRedux(tweetIDString: tweetID), isActive:$isShowDetail , label:{EmptyView()} ).opacity(0.1).disabled(true)
                DetailIndicator(tweetIDString: tweetID)
                    .onTapGesture {
                        store.dipatch(.fetchSession(tweetIDString: tweetID))
                        isShowDetail = true }

            }.fixedSize()
        }
    }
    
    var careated: some View {
        CreatedTimeView(createdTime: "now")
    }
    
    var text: some View {
        Text(status["text"].string ?? "Text")
    }
    var body: some View {
        VStack{
            HStack {
                avatar
                VStack(alignment: .leading){
                    nameAndcreated
                    text
                        .onTapGesture {
                            withAnimation{store.dipatch(.selectTweetRow(tweetIDString: status["id_str"].string ?? ""))}
                            
                        }
                }
                
            }.padding()
            if let imageUrls = getImagesUrls(status: status) {
            Images(imageUrlStrings: imageUrls)
                .frame(width: width - 2 * 16)
                .clipped()
            }
        }
        .background(Color.init("BackGroundLight"))
        .cornerRadius(16, antialiased: true)
        
        .overlay(RoundedRectangle(cornerRadius: 16)
         .stroke(Color.init("BackGroundLight"), lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
    
    func getImagesUrls(status: JSON) -> [String]? {
        guard let medias = status["extended_entities"]["media"].array else {return nil}
        let imageUrls = medias.map{$0["media_url_https"].string!}
        return imageUrls
    }
    
}
