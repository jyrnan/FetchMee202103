//
//  LogMessageView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/16.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData

struct LogMessageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Log.createdAt, ascending: true)]) var logs: FetchedResults<Log>
    
    let timeFormat: DateFormatter = {
        let format = DateFormatter()
        format.dateStyle = .short
        format.timeZone = .current
        format.timeStyle = .short
        return format
    }()
    
    var body: some View {
        List {
            LazyVStack(alignment: .leading){
            ForEach(logs) { log in
                Text("<" + timeFormat.string(from: log.createdAt!) + "> " + (log.text ?? "pay")).font(.callout)
                   
                            
                    }.onDelete(perform: { indexSet in
                        deleteLog(offsets: indexSet)
                    })
            }
        }
        .navigationBarTitle("LogMessage")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {deleteAll()}, label: {Text("Clear")}))
    }
}

struct LogMessageView_Previews: PreviewProvider {
    static var previews: some View {
        LogMessageView()
    }
}

extension LogMessageView {
    
    func deleteLog(offsets: IndexSet) {
        offsets.map{logs[$0]}.forEach{viewContext.delete($0)}
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError.description)
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func deleteAll() {
        logs.forEach{viewContext.delete($0)}
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError.description)
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
