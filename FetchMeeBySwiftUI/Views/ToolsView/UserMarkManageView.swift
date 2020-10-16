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
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \NickName.createdAt, ascending: true)]) var nickNames: FetchedResults<NickName>
    
    
    var body: some View {
        List {
            ForEach(nickNames, id: \.self) { nickName in
                NavigationLink(
                    destination: UserInfo(userIDString: nickName.id)) {
                HStack {
                    Text(nickName.nickName ?? "NickName").frame(width: 100, alignment: .leading)
                    Text(nickName.name ?? "Name").bold().frame(width: 120, alignment: .leading)
                    Text(nickName.id ?? "0123456789").lineLimit(1).frame(alignment: .leading).foregroundColor(.gray)
                }
                }
            }
            .onDelete(perform: { indexSet in
                deleteNickNames(offsets: indexSet)
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
    
    private func deleteNickNames(offsets: IndexSet) {
        offsets.map{ nickNames[$0]}.forEach(viewContext.delete)
        
        do {
            try viewContext.save()
        }catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
