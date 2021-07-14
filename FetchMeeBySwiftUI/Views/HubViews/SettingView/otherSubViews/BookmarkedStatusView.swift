//
//  BookmarkedStatusView.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/13.
//  Copyright © 2021 jyrnan. All rights reserved.
//


import SwiftUI
import CoreData
import Combine

struct BookmarkedStatusView: View {
    @EnvironmentObject var store: Store
    
    var userID: String?
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \StatusCD.id_str, ascending: false),
                                    NSSortDescriptor(keyPath: \StatusCD.created_at, ascending: false)]) var statuses: FetchedResults<StatusCD>
    
    ///用来筛选保存在CoreData推文，
    ///如果传入具体的userID，则返回该ID的推文
    ///如果没有具体的user ID，则返回所有非本人的推文，也就是收藏的推文
    var filterStatus: [StatusCD] {userID == nil ? statuses.filter{$0.user?.userIDString != store.appState.setting.loginUser?.id} : statuses.filter{$0.user?.userIDString == userID}}
    
    var body: some View {
        GeometryReader { proxy in
            List{
                ForEach(filterStatus, id: \.id) {status in
                    StatusRow(status: status.convertToStatus(), width: proxy.size.width - 32)
                        
                        .background(Color.init("BackGround"))
                        .cornerRadius(16)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                        
                }
                .onDelete(perform: { indexSet in
                            deleteTags(offsets: indexSet)})
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0,trailing: 0))
            }
            .listStyle(.plain)
            .navigationTitle("Bookmarks")
            .navigationBarItems(trailing: Button(action: {deleteAll()}, label: {Text("Clear")}))
        }
        
    }
    
}


extension BookmarkedStatusView {
    private func deleteAll() {
        filterStatus.forEach{viewContext.delete($0)}
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError.description)
        }
    }
    
    private func deleteTags(offsets: IndexSet) {
        offsets.map{ filterStatus[$0]}.forEach(viewContext.delete)
        
        do {
            try viewContext.save()
        }catch {
            let nsError = error as NSError
            print(nsError.description)
        }
    }
}
