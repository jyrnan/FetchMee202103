//
//  LogMessageSmallView.swift
//  FetchMee
//
//  Created by jyrnan on 11/7/20.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct LogMessageSmallView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Log.createdAt, ascending: true)]) var logs: FetchedResults<Log>
    
    let timeFormat: DateFormatter = {
        let format = DateFormatter()
        format.dateStyle = .none
        format.timeZone = .current
        format.timeStyle = .short
        return format
    }()
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading){
            ForEach(logs) { log in
                Text("<" + timeFormat.string(from: log.createdAt!) + "> " + (log.text ?? "pay")).font(.caption2).foregroundColor(.white)
                        
                    }
            }
        }
        
    }
}


struct LogMessageSmallView_Previews: PreviewProvider {
    static var previews: some View {
        LogMessageSmallView()
    }
}
