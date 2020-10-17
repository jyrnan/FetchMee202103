//
//  NickNameManageView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/16.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

struct UserMarkManageView: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TwitterUser.userIDString, ascending: true)]) var twitterUsers: FetchedResults<TwitterUser>
    
    
    var body: some View {
        List {
            ForEach(twitterUsers, id: \.self) { user in
                NavigationLink(
                    destination: UserInfo(userIDString: user.userIDString)) {
                HStack {
                    Text(user.nickName ?? "NickName").frame(width: 100, alignment: .leading)
                    Text(user.name ?? "Name").bold().frame(width: 120, alignment: .leading)
                    Text(user.userIDString ?? "0123456789").lineLimit(1).frame(alignment: .leading).foregroundColor(.gray)
                }
                }
            }
            .onDelete(perform: { indexSet in
                deleteUser(offsets: indexSet)
            })
        }.navigationBarTitle("UserMark")
    }
}

struct UserMarkManageView_Previews: PreviewProvider {
    static var previews: some View {
        UserMarkManageView()
    }
}

extension UserMarkManageView {
    
    private func deleteUser(offsets: IndexSet) {
        offsets.map{ twitterUsers[$0]}.forEach(viewContext.delete)
        
        do {
            try viewContext.save()
        }catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
