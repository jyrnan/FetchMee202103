//
//  StatusRow.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/14.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import KingfisherSwiftUI
import CoreData

struct StatusRow: View {
    
    var status: Status_CD
    
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
        Text(status.text ?? "Text")
    }
    var body: some View {
        VStack{
            HStack(alignment: .top) {
                avatar
                VStack(alignment: .leading){
                    nameAndcreated
                    text
                }
                
            }.padding()
            if status.imageUrls != nil {
                Images(imageUrlStrings: status.imageUrls!)
                .clipped()
            }
        }
        .background(Color.init("BackGroundLight"))
        .cornerRadius(16, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        .foregroundColor(Color.init(.label))
//        .onTapGesture {
//            print(status.user)
//        }
        
    }
    
}


struct StatusRow_Previews: PreviewProvider {
    
    static var previews: some View {
        StatusRow(status: Status_CD(context: PersistenceContainer.shared.container.viewContext))
    }
}
