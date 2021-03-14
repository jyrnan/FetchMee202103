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
        CreatedTimeView(createdTime: "now")
            Spacer()
        }
    }
    
    var careated: some View {
        CreatedTimeView(createdTime: "now")
    }
    
    var text: some View {
        Text(status.text ?? "CoreData: CloudKit: CoreData+CloudKit: -[NSCloudKitMirroringDelegate checkAndExecuteNextRequest]_block_invoke(2468): <NSCloudKitMirroringDelegate: 0x280198ea0>: No more requests to execute")
    }
    var body: some View {
        VStack{
            HStack {
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
        .background(Color.init("BackGround"))
        .cornerRadius(16, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        .padding()
        
    }
    
}


struct StatusRow_Previews: PreviewProvider {
    
    static var previews: some View {
        StatusRow(status: Status_CD(context: PersistenceContainer.shared.container.viewContext))
    }
}
