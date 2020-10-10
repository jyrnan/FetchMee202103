//
//  HubView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/10.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct HubView: View {
    
    //    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    //    @EnvironmentObject var downloader: Downloader
    //
    //    @StateObject var home = Timeline(type: TweetListType.home)
    //    @StateObject var mentions = Timeline(type: TweetListType.mention)
    
    @State var tweetText: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView{
            ZStack{
                RoundedCorners(color: Color.init("BackGround"), tl: 18, tr: 18, bl: 0, br: 0)
                    .padding(.top, 0)
                    .padding(.bottom, -164)
                    .shadow(radius: 3 )
                    
                
                
               VStack {
                    ComposerOfHubView(isShowCMV: .constant(false), tweetText: $tweetText)
                        .padding(.top, 16)
                        .padding([.leading, .trailing], 18)
                    
                    //Timeline
                    VStack {
                        HStack {
                            Text("Timeline").font(.caption).bold().foregroundColor(Color.gray)
                            Spacer()
                        }.padding(.leading,16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<5) { index in
                                    NavigationLink(
                                        destination: TimelineView()){
                                    RoundedRectangle(cornerRadius: 18)
                                        .frame(width: 92, height: 92, alignment: .center)
                                        .foregroundColor(Color.init(UIColor.systemBackground))
                                        .shadow(color: Color.black.opacity(0.4), radius: 3, x: 0, y: 3)
                                    }
                                }
                                .padding(.leading, 16).padding(.top, 4).padding(.bottom, 8)
                            }
                        }.padding(0)
                    }
                    
                    //Tools
                    VStack(spacing: 16) {
                        HStack {
                            Text("Tools").font(.caption).bold().foregroundColor(Color.gray)
                            Spacer()
                        }
                        ForEach(0..<3){index in
                            RoundedRectangle(cornerRadius: 18)
                                .frame(width: 334, height: 76, alignment: .center).foregroundColor(Color.init(UIColor.systemBackground)).shadow(color: Color.black.opacity(0.4),radius: 3, x: 0, y: 3)
                        }
                    }.padding([.leading, .trailing], 16)
                }
            }
            .navigationTitle("FetchMee")
            .navigationBarItems(trailing:NavigationLink(destination: SettingView()) {
                Image(uiImage: (self.user.myInfo.avatar ?? UIImage(systemName: "person.circle.fill")!))
                    .resizable()
                    .frame(width: 32, height: 32, alignment: .center)
                    .clipShape(Circle())
                
            })
            }
        }
        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
            self.hideKeyboard()
        })
    }
}

struct HubView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            HubView().environmentObject(User())
            HubView().environmentObject(User()).environment(\.colorScheme, .dark)
        }
    }
}


extension HubView {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
