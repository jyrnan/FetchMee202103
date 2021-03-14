//
//  BookmarkedStatusView.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/13.
//  Copyright © 2021 jyrnan. All rights reserved.
//


import SwiftUI
import CoreData
import KingfisherSwiftUI

struct BookmarkedStatusView: View {
    @EnvironmentObject var store: Store
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Status_CD.id_str, ascending: false),
                                    NSSortDescriptor(keyPath: \Status_CD.created_at, ascending: false)]) var statuses: FetchedResults<Status_CD>
    
    var body: some View {
        List{
            ForEach(statuses, id: \.self) {status in
                StatusRow(status: status)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 16)
            }
            .onDelete(perform: { indexSet in
                        deleteTags(offsets: indexSet)})
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0,trailing: 0))
        }
        .onAppear(perform: {
            UITableView.appearance().separatorColor = .clear
        })
        .navigationTitle("Bookmarks")
        .navigationBarItems(trailing: Button(action: {deleteAll()}, label: {Text("Clear")}))
    }
    
}


extension BookmarkedStatusView {
    private func deleteAll() {
        statuses.forEach{viewContext.delete($0)}
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError.description)
        }
    }
    
    private func deleteTags(offsets: IndexSet) {
        offsets.map{ statuses[$0]}.forEach(viewContext.delete)
        
        do {
            try viewContext.save()
        }catch {
            let nsError = error as NSError
            print(nsError.description)
        }
    }
}
