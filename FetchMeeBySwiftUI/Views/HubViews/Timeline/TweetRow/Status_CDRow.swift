//
//  StatusRow.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/14.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import Kingfisher
import CoreData

struct Status_CDRow: View {
    
    var status: StatusCD
    var width: CGFloat
    
    var avatar: some View {
        VStack(alignment: .leading){
            AvatarView(userIDString: status.user?.userIDString ?? "", width: 36, height: 36)
            Spacer()
        }
    }
    
    var nameAndcreated: some View {
        HStack{
        UserNameView(userName: status.user?.name ?? "Name",
                     screenName: status.user?.screenName ?? "screenName")
            CreatedTimeView(created_at: status.created_at)
            Spacer()
        }
    }
    
    var careated: some View {
        CreatedTimeView(createdTime: "now")
    }
    
    var text: some View {
        Text(status.text ?? "Text").fixedSize(horizontal: false, vertical: true)
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
            
            if status.imageUrls != nil {
                Images(imageUrlStrings: status.getImageUrls()!)
                    .frame(width: width, height: width * 9 / 21)
                .clipped()
            }
        }
        .background(Color.init("BackGroundLight"))
        .cornerRadius(16, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        .foregroundColor(Color.init(.label))
        
    }
    
    
    
    
}
