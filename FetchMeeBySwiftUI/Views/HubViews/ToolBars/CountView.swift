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
    
    
    let format: DateFormatter = {
        var format = DateFormatter()
        format.dateStyle = .short
        format.timeStyle = .short
        format.timeZone = .current
        return format
    }()
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Date: ").bold().frame(alignment: .leading).padding()
                Spacer()
                Text("Follower: ").bold().frame(alignment: .leading)
                Spacer()
                Text("Following: ").bold().frame(alignment: .leading)
                Spacer()
                Text("Tweets: ").bold().frame(alignment: .leading)
                Spacer()
                Text("User: ").bold().frame(alignment: .leading)
                
            }.font(.caption2).frame(height: 18).background(Color.gray)
            
        List {
//            LazyVStack{
            ForEach(counts, id: \.self) { count in
                HStack {
                    Text(format.string(from: count.createdAt ?? Date())).frame(alignment: .leading)
                    Spacer()
                    Text("\(count.follower)").frame(alignment: .leading)
                    Spacer()
                    Text("\(count.following)").frame(alignment: .leading)
                    Spacer()
                    Text("\(count.tweets)").frame(alignment: .leading).foregroundColor(.gray)
                    Spacer()
                    Text("\(count.countToUser?.name ?? "Unknow")").frame(alignment: .leading).foregroundColor(.gray)
                }.font(.body)
                
            }.onDelete(perform: { indexSet in
                        deleteCounts(offsets: indexSet)
                    })
//            }
        }
        .navigationBarTitle("Logs", displayMode: .inline)
        .navigationBarTitleDisplayMode(.inline)
    }
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

extension CountView {
    
    func deleteLog(offsets: IndexSet) {
        offsets.map{counts[$0]}.forEach{viewContext.delete($0)}
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func deleteAll() {
        counts.forEach{viewContext.delete($0)}
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
