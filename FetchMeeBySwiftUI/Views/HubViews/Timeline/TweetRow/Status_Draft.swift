//
//  draft_Draft.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/28.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI

struct Status_Draft: View {

    
    var draft: TweetDraft?
    var width: CGFloat
    
    var avatar: some View {
        VStack(alignment: .leading){
            AvatarView(userIDString: draft?.user?.userIDString ?? "", width: 36, height: 36)
            Spacer()
        }
    }
    
    var nameAndcreated: some View {
        HStack{
            UserNameView(userName: draft?.user?.name ?? "Name",
                     screenName: draft?.user?.screenName ?? "screenName")
            CreatedTimeView(created_at: draft?.createdAt ?? Date())
            Spacer()
        }
    }
    
    var careated: some View {
        CreatedTimeView(createdTime: "now")
    }
    
    var text: some View {
        Text(draft?.text ?? "First draft").fixedSize(horizontal: false, vertical: true)
    }
    var body: some View {
        
        VStack{
            HStack(alignment: .top) {
                avatar
                VStack(alignment: .leading){
                    nameAndcreated
                    text.padding(.top, 4)
                }
                
            }.padding()
//            if draft.imageUrls != nil {
//                Images(imageUrlStrings: (draft.imageUrls?.split(separator: " ").map{String($0)})!)
//                    .frame(width: width, height: width * 9 / 21)
//                .clipped()
//            }
        }
        .background(Color.init("BackGroundLight"))
        .cornerRadius(16, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        .foregroundColor(Color.init(.label))
        
    }
    
}
