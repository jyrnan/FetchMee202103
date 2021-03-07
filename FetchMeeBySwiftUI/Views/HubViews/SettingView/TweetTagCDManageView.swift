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
        
    }
}

struct TweetTagCDManageView_Previews: PreviewProvider {
    static var previews: some View {
        TweetTagCDManageView()
    }
}
