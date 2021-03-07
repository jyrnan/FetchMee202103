//
//  TweetTagCDManageView.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/7.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData

struct TweetTagCDManageView: View {
    @EnvironmentObject var store: Store
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetTagCD.priority, ascending: false)]) var tweetTags: FetchedResults<TweetTagCD>
    
    var body: some View {
        List{
            ForEach(tweetTags, id: \.self) {tag in
                Text(tag.text ?? "")
            }
        }
        .navigationTitle("TweetTags")
        .navigationBarItems(trailing: Button(action: {deleteAll()}, label: {Text("Clear")}))
    }
}

struct TweetTagCDManageView_Previews: PreviewProvider {
    static var previews: some View {
        TweetTagCDManageView()
    }
}

extension TweetTagCDManageView {
    private func deleteAll() {
        tweetTags.forEach{viewContext.delete($0)}
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError.description)
    }
}
}
