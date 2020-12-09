//
//  Composer.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData

struct Composer: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var fetchMee: User
    
    @Environment(\.managedObjectContext) var viewContext
    
    @State var tweetText: String = ""
    
    @State var isShowCMV: Bool = false  //是否显示详细新推文视图
    
    @Binding var isProcessingDone: Bool
    
    var tweetIDString: String?
    
    
    var body: some View {
        HStack(alignment: .center) {
            TextField("Tweet something here...", text: $tweetText).font(.body).padding(.leading, 16)
            Spacer()
            ///显示详细发推视图或者菊花
            if isProcessingDone {
                
                NavigationLink(
                    destination: ComposerOfHubView(tweetText: self.$tweetText, replyIDString: self.tweetIDString, isUsedAlone: true ),
                    isActive: $isShowCMV
                ){
                    Text("more").font(.body).foregroundColor(.primary).opacity(0.7)}
                .onTapGesture {self.isShowCMV = true }
                
            } else {
                                    ActivityIndicator(isAnimating: $isProcessingDone, style: .medium)
            }
            
            Divider()
            
            Button(action: {
                isProcessingDone = false
                swifter.postTweet(status: self.tweetText, inReplyToStatusID: tweetIDString, autoPopulateReplyMetadata: true, success: {_ in
                    self.tweetText = ""
                    self.alerts.stripAlert.alertText = "Tweet sent!"
                    self.alerts.stripAlert.isPresentedAlert = true
                    isProcessingDone = true
                })
                self.hideKeyboard()
            },
            label: {
                Image(systemName: "plus.message.fill").resizable().aspectRatio(contentMode: .fill).frame(width: 20, height: 20, alignment: .center).padding(.trailing, 18)
                    .foregroundColor(self.tweetText == "" ? Color.primary.opacity(0.3) : Color.primary.opacity(0.8) )
            }).disabled(tweetText == "")
            
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
        Composer(isProcessingDone: .constant(false))
    }
}