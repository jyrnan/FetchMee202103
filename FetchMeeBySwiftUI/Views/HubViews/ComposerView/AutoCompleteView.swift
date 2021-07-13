//
//  AutoCompleteVIew.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/5.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData

struct AutoCompleteView: View {
    @EnvironmentObject var store: Store
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \UserCD.userIDString, ascending: true)]) var userCDs: FetchedResults<UserCD>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetTagCD.priority, ascending: false),
                                    NSSortDescriptor(keyPath: \TweetTagCD.createdAt, ascending: false)]) var tweetTags: FetchedResults<TweetTagCD>
    
    var screenNames: [String] {
        userCDs.filter{($0.screenName?.starts(with: String(autoCompleteText.dropFirst()))) == true}
            .map{"@" + $0.screenName!}
    }
    
    
    var tagsCD: [String] {
        tweetTags.filter{($0.text?.hasPrefix(String(autoCompleteText.dropFirst()))) == true}
            .map{"#" + $0.text!}
    }
    
    var autoCompleteText: String
    var namesOrTags: [String] {
//        print(#line, #file, "Running autoCompleteText")
        return autoCompleteText.first == "@" ? screenNames : tagsCD
    }
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false){
            HStack {
                ForEach(namesOrTags, id: \.self) {nameOrTag in
                    Text(nameOrTag).foregroundColor(.white)
                    .font(.caption)
                    .padding(6)
                    .background(Color.accentColor)
                    .cornerRadius(16)
                    .onTapGesture {
                        store.dispatch(.autoComplete(text: nameOrTag))
                        guard nameOrTag.starts(with: "#") else {return}
                        let tagText = String(nameOrTag.dropFirst())
                        TweetTagCD.saveTag(text: tagText, priority: 1)
                    }
            }
            }
        }
    }
}

struct AutoCompleteVIew_Previews: PreviewProvider {
    static var store = Store()
    static var previews: some View {
        AutoCompleteView(autoCompleteText: "emxample").environmentObject(store)
    }
}

