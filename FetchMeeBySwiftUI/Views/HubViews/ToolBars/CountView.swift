//
//  CountView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/17.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

struct CountView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Count.createdAt, ascending: true)]) var counts: FetchedResults<Count>
    
    
    
    var body: some View {
        List {
            ForEach(counts, id: \.self) { count in
//                NavigationLink(
//                    destination: UserInfo(userIDString: count.userIDString)) {
                HStack {
                    Text("Follower: \(count.follower)").frame(alignment: .leading)
                    Text("Following: \(count.following)").frame(alignment: .leading)
                    Text("Tweets: \(count.tweets)").frame(alignment: .leading).foregroundColor(.gray)
                    Text("Tweets: \(count.countToUser?.name ?? "Unknow")").frame(alignment: .leading).foregroundColor(.gray)
                }
//                }
            }.onDelete(perform: { indexSet in
                        deleteCounts(offsets: indexSet)
                    })
               
        }.navigationBarTitle("Drafts")
    }
}

extension CountView {
    
    private func deleteCounts(offsets: IndexSet) {
        offsets.map{ counts[$0]}.forEach(viewContext.delete)
        
        do {
            try viewContext.save()
        }catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
