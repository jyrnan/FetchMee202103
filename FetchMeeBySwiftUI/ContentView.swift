//
//  ContentView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import SwifteriOS
import Combine


struct ContentView: View {
    @ObservedObject var home = Timeline(type: TweetListType.home)
    @ObservedObject var mentions = Timeline(type: TweetListType.mention)
    
    @ObservedObject var user: User
    
    @State var tweetText: String = ""
    
    @State var isFirstRun: Bool = true //设置用于第一次运行刷新的时候标志
    
    @State var isHiddenMention: Bool = false
    
//    @State var isPresentedAlert: Bool = false
//    @State var alertText: String = ""
    
    @EnvironmentObject var alerts: Alerts
  
    var body: some View {
        NavigationView{
            ZStack {
                if #available(iOS 14.0, *) {
                    List {
                        Composer(timeline: self.home)
                           
                        Section(header:
                                    HStack {
                                        Button(action: { self.isHiddenMention.toggle() },
                                                   label: {Text("Mentions").font(.headline)})
                                        Spacer()
                                        if !self.isHiddenMention {
                                            Button(action: {self.mentions.refreshFromTop()}, label: {
                                            Image(systemName: "arrow.clockwise")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 18, height: 18)
                                                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 4)
                                            })
                                        } else {
                                            /*@START_MENU_TOKEN@*/EmptyView()/*@END_MENU_TOKEN@*/
                                        }
                                    })
                        {
                            if !isHiddenMention {
                                TweetsList(timeline: self.mentions, tweetListType: TweetListType.mention)
                            HStack {
                                Spacer()
                                Button("More Tweets...") {
                                    self.mentions.refreshFromButtom()}
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            }
                        }
                        Section(header:
                                    HStack {
                                        Text("Homeline").font(.headline)
                                        Spacer()
                                        Button(action: {self.home.refreshFromTop()}, label: {
                                        Image(systemName: "arrow.clockwise")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 18, height: 18)
                                            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 4)
                                        })
                                    })
                        {
                            TweetsList(timeline: self.home, tweetListType: TweetListType.home)
                            HStack {
                                Spacer()
                                Button("More Tweets...") {
                                    
                                    self.home.refreshFromButtom()}
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle("FetchMee")
                    .navigationBarItems(trailing: Image(uiImage: (self.user.myInfo.avatar ?? UIImage(systemName: "person.circle.fill")!))
                                            .resizable()
                                            .frame(width: 32, height: 32, alignment: .center)
                                            .clipShape(Circle())
                                            .onLongPressGesture {
                                                self.alerts.standAlert.isPresentedAlert.toggle()
                                            }
                                            .alert(isPresented: self.$alerts.standAlert.isPresentedAlert) {
                                                Alert(title: Text("LogOut?"), message: nil, primaryButton: .default(Text("Logout"), action: {self.logOut()})
                                                , secondaryButton: .cancel())
                                            }
                                            )
                }
                VStack {
                    if self.alerts.stripAlert.isPresentedAlert {
                        AlertView(isAlertShow: self.$alerts.stripAlert.isPresentedAlert, alertText: self.alerts.stripAlert.alertText)
                    }
                    Spacer()
                }
                
            }
            
        }
    }
}

extension ContentView {
    
    func refreshAll() {
        self.home.refreshFromTop()
        self.mentions.refreshFromTop()
        
        
    }
    
    func logOut() {
        self.user.isLoggedIn = false
        userDefault.set(false, forKey: "isLoggedIn")
        userDefault.set(nil, forKey: "userIDString")
        userDefault.set(nil, forKey: "screenName")
        print(#line)
    }
}

//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(user: User())
    }
}
