//
//  Homeline.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

enum TweetListType: String {
    case home = "Home"
    case mention = "Mentions"
    case list
    case user
}

struct TweetsList: View {
    @State var tweetListType: TweetListType
    @ObservedObject var timeline = Timeline()
    
    @State var presentedModal: Bool = false //用于标志是否显示ModalView，例如Composer
    
    @State var isFirstRun: Bool = true //设置用于第一次运行的时候标志
    
    var body: some View {
        NavigationView {
            VStack {
                
                List {
                    HStack {
                        Spacer()
                        Button("Refresh Tweets...") {self.timeline.getJSON(type: self.tweetListType)}
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    
                   
                    ForEach(self.timeline.tweetIdStrings, id: \.self) {
                        
                        tweetIDString in
                        
                       
                            ZStack {
                               
                                TweetRow(tweetMedia: self.timeline.tweetMedias[tweetIDString]!)
                                    
                                NavigationLink(destination: DetailView()) {
                                    EmptyView()
                                    Spacer()
                                }
                             
                        }
                       
                    }
                    
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom:0, trailing: 0))
                    
                }
                .listStyle(PlainListStyle())
//                .listRowBackground(Color.white).opacity(0)
               
            }
            .navigationBarTitle(self.tweetListType.rawValue)
        .navigationBarItems(trailing: Button("New", action: { self.presentedModal = true})
                                .sheet(isPresented: $presentedModal, onDismiss: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=On Dismiss@*/{ }/*@END_MENU_TOKEN@*/) {
                                    Composer(presentedModal: $presentedModal)
                                }
        )
        }
    .onAppear(perform: {
        if self.isFirstRun {
            self.timeline.getJSON(type: self.tweetListType)
            self.isFirstRun.toggle()
        }
    })
        
    }
}

struct TweetsList_Previews: PreviewProvider {
    static var previews: some View {
        TweetsList(tweetListType: TweetListType.home)
    }
}
