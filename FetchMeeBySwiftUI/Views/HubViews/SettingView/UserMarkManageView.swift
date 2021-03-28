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
    @EnvironmentObject var store: Store
//    @EnvironmentObject var fetchMee: User
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TwitterUser.nickName, ascending: false)]) var twitterUsers: FetchedResults<TwitterUser>
    
    @State var presentedUserInfo: Bool = false
    
    var body: some View {
        List {
            ForEach(twitterUsers, id: \.self) { user in
                NavigationLink(
                    destination: UserViewRedux(userIDString: user.userIDString!)) {
                HStack {
                    Text(user.nickName ?? "").frame(width: 80, alignment: .leading)
                    Text(user.name ?? "Name").bold().lineLimit(1).frame(width: 120, alignment: .leading)
                    Text("@" + (user.screenName ?? "screenName")).lineLimit(1).frame(alignment: .leading).foregroundColor(.gray)
                        .onTapGesture {
                            let user = UserInfo(id: user.userIDString!)
                            store.dipatch(.userRequest(user: user, isLoginUser: false))
                            presentedUserInfo = true
                        }
                }
                
                }
            }
            .onDelete(perform: { indexSet in
                deleteUser(offsets: indexSet)
            })
        }
        .navigationTitle("UserMark")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {deleteAll()}, label: {Text("Clear")}))
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
            print(nsError.description)
        }
    }
    
    private func deleteAll() {
//        twitterUsers.forEach{viewContext.delete($0)}
        twitterUsers.filter{$0.isLocalUser == false}.forEach{viewContext.delete($0)}
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError.description)
    }
}
}
