//
//  ToolsView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/16.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter

struct ToolsView: View {
    @EnvironmentObject var store: Store
    
    @State var isShowSafari: Bool = false
    @State var url: URL = URL(string: "https://www.twitter.com")!
    
    @State var isAlertShowed: Bool = false
    
    var status: Status
    
    var retweeted: Bool { status.retweeted }
    var retweetedCount: Int {status.retweet_count }
    
    var favorited: Bool { status.favorited }
    var favoritedCount: Int {status.favorite_count }
    
    var isMyTweet: Bool = false
//    {status?.user?.id == store.appState.setting.loginUser?.id}
    //直接用计算属性会导致预览失效
    //可以吧这个属性编程函数返回相应值，在需要的地方调用
    
    var body: some View {
        VStack {
            HStack{
                
                Image(systemName: isTweetByMeself() ? "trash" : "bookmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18, alignment: .center)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        if isMyTweet {
                            store.dispatch(.tweetOperation(operation: .delete(id: status.id)))
                        } else {

                            store.fetcher.swifter.getTweet(for: status.id, success: {json in
                                let _ = StatusCD.JSON_Save(from: json, isBookmarked: true)
                                store.dispatch(.alertOn(text: "Bookmarked!", isWarning: false))
                                store.dispatch(.hubStatusRequest)
                            })
                            
                        }
                    }
                    .alert(isPresented: self.$isAlertShowed, content: {
                        Alert(title: Text("You can't delete this tweet"))
                    })
                
                Spacer()
                
                Image(systemName: retweeted ? "repeat.1" : "repeat")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18, alignment: .center)
                    .foregroundColor(retweeted == true ? Color.green : Color.gray)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        store.dispatch(.tweetOperation(operation: retweeted ? .unRetweet(id: status.id) : .retweet(id: status.id)))
                    }
                
                if retweetedCount != 0 {
                    Text(String(retweetedCount)).font(.subheadline) }
                Spacer()
                
                Image(systemName: favorited ? "heart.fill" : "heart")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18, alignment: .center)
                    .foregroundColor(favorited ? Color.red : Color.gray)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        store.dispatch(.tweetOperation(operation: favorited ? .unfavorite(id: status.id) : .favorite(id: status.id)))
                    }
                
                if favoritedCount != 0 {
                    Text(String(favoritedCount)).font(.subheadline) }
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18, alignment: .center)
                    .onTapGesture {
                        if let screenName = status.user?.screenName
                           {
                            self.url = URL(string: "https://twitter.com/\(screenName)/status/\(status.id)")!
                        }
                        self.isShowSafari = true
                    }
                    .sheet(isPresented: self.$isShowSafari, content: {
                        SafariView(url: self.$url)
                    })
                
            }.foregroundColor(.gray).padding(.horizontal, 16).padding(.top, 4)
            
            Composer(tweetTextBinding: $store.appState.setting.tweetInput.tweetText,
                     isProcessingDone: $store.appState.setting.isProcessingDone,
                     status: status)
                .padding(.top, 4)
                .padding(.bottom, 4)
                .padding(.horizontal, 16)
                .frame(height: 42)
                .background(Color.accentColor.opacity(0.4))
                .cornerRadius(store.appState.setting.userSetting?.uiStyle.radius ?? 0)
            
        }
        .font(.body)
    }
}



extension ToolsView {
    func isTweetByMeself() -> Bool {
        return status.user?.id == store.appState.setting.loginUser?.id
    }
}

struct ToolsView_Previews: PreviewProvider {
    static let store = Store()
    static var previews: some View {
        ToolsView(status: Status())
            .environmentObject(store)
    }
}
