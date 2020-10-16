//
//  DraftsView.swift
//  FetchMee
//
//  Created by yoeking on 2020/8/19.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

struct DraftsViewCoreData: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetDraft.createdAt, ascending: true)]) var drafts: FetchedResults<TweetDraft>
    
    
    @Binding var currentTweetDraft: TweetDraft?
    @Binding var tweetText: String
    @Binding var replyIDString: String?
    
    var body: some View {
        List {
            ForEach(drafts) { draft in
                        Text(draft.text ?? "pay")
                            .onTapGesture(count: 1, perform: {
                                currentTweetDraft = draft as TweetDraft
                                tweetText = draft.text ?? ""
                                replyIDString = draft.replyIDString
                                self.presentationMode.wrappedValue.dismiss()
                            })
                    }.onDelete(perform: { indexSet in
                        deleteDrafts(offsets: indexSet)
                    })
               
        }.navigationBarTitle("Drafts")
    }
}

extension DraftsViewCoreData {
    
    private func deleteDrafts(offsets: IndexSet) {
        offsets.map{ drafts[$0]}.forEach(viewContext.delete)
        
        do {
            try viewContext.save()
        }catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
