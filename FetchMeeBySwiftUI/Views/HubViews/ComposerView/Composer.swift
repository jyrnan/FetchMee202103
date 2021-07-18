//
//  Composer.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData
import Combine

struct Composer: View {
    @EnvironmentObject var store: Store
    
    @Environment(\.managedObjectContext) var viewContext
    
    var tweetTextBinding: Binding<String>
    
    @State var isShowCMV: Bool = false  //是否显示详细新推文视图
    
    @Binding var isProcessingDone: Bool
    
    var status: Status?
    
    var body: some View {
        HStack(alignment: .center) {
            TextField("reply",
                      text: tweetTextBinding,
                      prompt: Text("Replying here..."))
                .font(.body)
            
            Spacer()
            ///显示详细发推视图或者菊花
            
                ZStack{

                    Text("more")
                        .font(.body)
                        .foregroundColor(.primary)
                        .opacity(0.7)
                        .onTapGesture {self.isShowCMV = true }
                }
                .fixedSize() //可以减少空间的占用量，否则会占据一半的有用空间
                .sheet(isPresented: $isShowCMV){ComposerOfHubView(swifter: store.fetcher.swifter,
                                                                  tweetText: tweetTextBinding,
                                                                  replyIDString: status?.id,
                                                                  isUsedAlone: true,
                status: status)
                .accentColor(store.appState.setting.userSetting?.themeColor.color)
                }
           
            
            Divider()
            
            Button(action: {
                isProcessingDone = false
                store.fetcher.swifter.postTweet(status: tweetTextBinding.wrappedValue,
                                                inReplyToStatusID: status?.id,
                                                autoPopulateReplyMetadata: true,
                                                success: {_ in
                    tweetTextBinding.wrappedValue = ""
                    store.dispatch(.alertOn(text: "Reply sent", isWarning: false))
                    isProcessingDone = true
                })
                self.hideKeyboard()
            },
                   label: {
                Image(systemName: "plus.message.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20, alignment: .center)
                    .opacity(isProcessingDone ? 1 : 0)
                    .overlay(ProgressView().opacity(isProcessingDone ? 0 : 1))
            })
                .disabled(tweetTextBinding.wrappedValue == "")
                .buttonStyle(PlainButtonStyle())
            
        }
    }
}

extension Composer {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct Composer_Previews: PreviewProvider {
    static var previews: some View {
        Composer(tweetTextBinding: .constant(""), isProcessingDone: .constant(true))
            .environmentObject(Store())
            .frame(width: nil, height: 60, alignment: .center)
    }
}
