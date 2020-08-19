//
//  DraftsView.swift
//  FetchMee
//
//  Created by yoeking on 2020/8/19.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

struct DraftsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var drafts: [[String]]
    @Binding var tweetText: String
    @Binding var replyIDString: String?
    @Binding var index: Int?
    
    var body: some View {
        List {
            
                    ForEach(self.drafts.indices, id: \.self) { index in
                        Text(self.drafts[index].first ?? "pay")
                            .onTapGesture(count: 1, perform: {
                                self.tweetText = self.drafts[index].first ?? "pay"
                                self.replyIDString = self.drafts[index].last == "0000" ? nil : self.drafts[index].last!
                                self.index = index
                                self.presentationMode.wrappedValue.dismiss()
                            })
                    }.onDelete(perform: { indexSet in
                        self.drafts.remove(atOffsets: indexSet)
                    })
               
        }.navigationBarTitle("Drafts")
    }
}

//struct DraftsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DraftsView()
//    }
//}
