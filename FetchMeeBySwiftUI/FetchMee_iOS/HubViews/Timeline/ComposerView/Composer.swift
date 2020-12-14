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
    
    var placeHolderText:String {tweetIDString == nil ? "Tweet something here..." : "Replying here..."}
    
    var body: some View {
        HStack(alignment: .center) {
            TextField(placeHolderText, text: $tweetText).font(.body)
//                .padding(.leading, 16)
            Spacer()
            ///显示详细发推视图或者菊花
            if isProcessingDone {
                ZStack{
                NavigationLink(
                    destination: ComposerOfHubView(tweetText: self.$tweetText, replyIDString: self.tweetIDString, isUsedAlone: true ),
                    isActive: $isShowCMV
                ){EmptyView().disabled(true)}
                    Text("more").font(.body).foregroundColor(.primary).opacity(0.7)
//                        .background(Color.init("BackGround"))
                .onTapGesture {self.isShowCMV = true }
                }
                .fixedSize() //可以减少空间的占用量，否则会占据一半的有用空间
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
                Image(systemName: "plus.message.fill").resizable().aspectRatio(contentMode: .fill).frame(width: 20, height: 20, alignment: .center)
                    .foregroundColor(self.tweetText == "" ? Color.primary.opacity(0.3) : Color.primary.opacity(0.8) )
            }).disabled(tweetText == "").buttonStyle(PlainButtonStyle())
            
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
