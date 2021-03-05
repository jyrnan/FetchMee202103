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
    
    var screenNames: [String] {
        twitterUsers.filter{($0.screenName?.starts(with: String(autoCompletText.dropFirst())))!}
            .map{$0.screenName!}
    }
    
    
    
    var autoCompletText: String
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false){
            HStack {
                ForEach(screenNames, id: \.self) {screenName in
                Text("@" + screenName).foregroundColor(.white)
                    .font(.caption)
                    .padding(2)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .onTapGesture {
                        store.dipatch(.autoComplete(text: "@" + screenName))
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

