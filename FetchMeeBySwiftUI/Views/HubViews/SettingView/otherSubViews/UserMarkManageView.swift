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
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \UserCD.isLoginUser, ascending: false),
                                    NSSortDescriptor(keyPath: \UserCD.isLocalUser, ascending: false),
                                    NSSortDescriptor(keyPath: \UserCD.isFavoriteUser, ascending: false),
                                    NSSortDescriptor(keyPath: \UserCD.updateTime, ascending: false)]) var userCDs: FetchedResults<UserCD>
    
    @State var presentedUserInfo: Bool = false
    
    var body: some View {
        List {
            ForEach(userCDs, id: \.self) { user in
                NavigationLink(
                    destination: UserView(user: User())) {
                HStack {
                    Text(user.nickName ?? "").frame(width: 80, alignment: .leading)
                    Text(user.name ?? "Name").bold().lineLimit(1).frame(width: 120, alignment: .leading)
                    Text("@" + (user.updateTime?.description ?? "N/A")).lineLimit(2).frame(alignment: .leading).foregroundColor(.gray)
                        .onTapGesture {
                            presentedUserInfo = true
                        }
                }.foregroundColor(user.isLoginUser ? .red : (user.isLocalUser ? .green : .gray))
                
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
        offsets.map{ userCDs[$0]}.forEach(viewContext.delete)
        do {
            try viewContext.save()
        }catch {
            let nsError = error as NSError
            print(nsError.description)
        }
    }
    
    private func deleteAll() {
        userCDs.filter{!$0.isLocalUser && !$0.isFavoriteUser && !$0.isBookmarkedUser && !$0.isLoginUser}.forEach{viewContext.delete($0)}
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError.description)
    }
}
}
