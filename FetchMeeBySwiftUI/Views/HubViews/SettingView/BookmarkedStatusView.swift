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
                                    NSSortDescriptor(keyPath: \Status_CD.text, ascending: false)]) var statuses: FetchedResults<Status_CD>
    
    var body: some View {
        List{
            ForEach(statuses, id: \.self) {status in
                HStack{
                Text(status.text ?? "")
                    Spacer()
                    Text(String(status.id_str!))
                    ForEach(status.images ?? [], id: \.self) {url in
                        KFImage(URL(string: url)).resizable().aspectRatio(contentMode: .fit)
                    }
                }
            }.onDelete(perform: { indexSet in
                        deleteTags(offsets: indexSet)})
        }
        .navigationTitle("TweetTags")
        .navigationBarItems(trailing: Button(action: {deleteAll()}, label: {Text("Clear")}))
    }
}

struct BookmarkedStatusView_Previews: PreviewProvider {
    static var previews: some View {
        TweetTagCDManageView()
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
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
