//
//  AutoCompleteVIew.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/5.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData

struct AutoCompleteVIew: View {
    @EnvironmentObject var store: Store
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TwitterUser.userIDString, ascending: true)]) var twitterUsers: FetchedResults<TwitterUser>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetTagCD.priority, ascending: false),
                                    NSSortDescriptor(keyPath: \TweetTagCD.createdAt, ascending: false)]) var tweetTags: FetchedResults<TweetTagCD>
    
    var screenNames: [String] {
        twitterUsers.filter{($0.screenName?.starts(with: String(autoCompletText.dropFirst())))!}
            .map{"@" + $0.screenName!}
    }
    
//    var tags: [String] {
//        Array((store.appState.setting.tweetTags ?? [])!)
//            .sorted{$0.priority > $1.priority}
//            .filter{$0.text.starts(with: String(autoCompletText.dropFirst()))}
//            .map{"#" + $0.text}
//    }
    
    var tagsCD: [String] {
        tweetTags.filter{($0.text?.starts(with: String(autoCompletText.dropFirst())))!}
            .map{"#" + $0.text!}
    }
    
    var autoCompletText: String
    var namesOrtags: [String] {autoCompletText.first == "@" ? screenNames : tagsCD}
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false){
            HStack {
                ForEach(namesOrtags, id: \.self) {nameOrtag in
                    Text(nameOrtag).foregroundColor(.white)
                    .font(.caption)
                    .padding(2)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .onTapGesture {
                        store.dipatch(.autoComplete(text: nameOrtag))
                        guard nameOrtag.starts(with: "#") else {return}
                        let tagText = String(nameOrtag.dropFirst())
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
        AutoCompleteVIew(autoCompletText: "emxample").environmentObject(store)
    }
}

