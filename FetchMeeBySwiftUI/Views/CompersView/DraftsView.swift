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

//struct DraftsView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @Binding var drafts: [[String]]
//    @Binding var tweetText: String
//    @Binding var replyIDString: String?
//    @Binding var index: Int?
//    
//    var body: some View {
//        List {
//            
//                    ForEach(self.drafts.indices, id: \.self) { index in
//                        Text(self.drafts[index].first ?? "pay")
//                            .onTapGesture(count: 1, perform: {
//                                self.tweetText = self.drafts[index].first ?? "pay"
//                                self.replyIDString = self.drafts[index].last == "0000" ? nil : self.drafts[index].last!
//                                self.index = index
//                                self.presentationMode.wrappedValue.dismiss()
//                            })
//                    }.onDelete(perform: { indexSet in
//                        drafts.remove(atOffsets: indexSet)
//                        print(drafts)
//                    })
//               
//        }.navigationBarTitle("Drafts")
//        .onDisappear {
//            writeDraftsToFile()
//        }
//    }
//}
//
//extension DraftsView {
//    func writeDraftsToFile() {
//        print(#line, "save drafts")
//        print(#line, drafts)
//        userDefault.setValue(self.drafts, forKey: "Drafts")
//    }
//}
//struct DraftsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DraftsView()
//    }
//}

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
