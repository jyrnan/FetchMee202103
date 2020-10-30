//
//  UserInfo.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData

struct UserInfo: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var fetchMee: AppData
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TwitterUser.userIDString, ascending: true)]) var twitterUsers: FetchedResults<TwitterUser>
    
    var userIDString: String? //传入需查看的用户信息的ID
    var userScreenName: String? //传入需查看的用户信息的Name
    
//    @Binding var checkingUser: User
    @StateObject var userTimeline: Timeline = Timeline(type: .user)
    @State var firstTimeRun: Bool = true //检测用于运行一次
    @State var isShowAvatarDetail :Bool = false //显示头像大图
    
    @State var nickNameText: String = ""
    @State var isNickNameInputShow: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                GeometryReader {
                    geometry in
                    Image(uiImage: fetchMee.users[userIDString!]?.banner ?? UIImage(named: "bg")!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width ,height: geometry.size.height - 55)
                        .clipped()
                        .padding(0)
                }
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        ///个人信息大头像
                        Image(uiImage: fetchMee.users[userIDString!]?.avatar ?? UIImage(systemName: "person.circle")!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 3))
                            .padding(.leading, 16)
                            .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                self.isShowAvatarDetail = true
//                                user.showingPicture = ImageViewer(image: self.checkingUser.myInfo.avatar ?? UIImage(systemName: "person.circle")!)
//                                user.isShowingPicture = true
                            })
                            .sheet(isPresented: self.$isShowAvatarDetail){
                                ImageViewer(image: fetchMee.users[userIDString!]?.avatar ?? UIImage(systemName: "person.circle")!)
                            }
                        Spacer()
                        //
                        
                        Image(systemName: "envelope")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.accentColor)
                            .padding(6)
                            .frame(width: 32, height: 32, alignment: .center)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.accentColor, lineWidth: 1))
                        Image(systemName: (self.fetchMee.users[userIDString!]?.notifications == true ? "bell.fill" : "bell"))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(fetchMee.users[userIDString!]?.notifications == true ? .white : .accentColor)
                            .padding(6)
                            .frame(width: 32, height: 32, alignment: .center)
                            .background(fetchMee.users[userIDString!]?.notifications == true ? Color.accentColor : Color.clear)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.accentColor, lineWidth: 1))
                        if fetchMee.users[userIDString!]?.isFollowing == true {
                            Text("Following")
                                .font(.body).bold()
                                .frame(width: 84, height: 32, alignment: .center)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .padding(.trailing, 16)
                                .onTapGesture(count: 1, perform: {
                                    fetchMee.unfollow()
                                })
                        } else {
                            Text("Follow")
                                .font(.body).bold()
                                .frame(width: 84, height: 32, alignment: .center)
                                .background(Color.primary.opacity(0.1))
                                .foregroundColor(.accentColor)
                                .cornerRadius(16)
                                .padding(.trailing, 16)
                                .onTapGesture(count: 1, perform: {
                                    fetchMee.follow()
                                })
                        }
                        
                    }
                }.padding(0)
            }.frame(height:180)
            
            ///用户信息View
            ScrollView {
                VStack(alignment: .leading){
                    HStack{
                        VStack(alignment: .leading) {
                            HStack {
                                
                                Text(fetchMee.users[userIDString!]?.name ?? "Name").font(.title2).bold()
                                if !isNickNameInputShow {
                                    Text(twitterUsers.filter{$0.userIDString == userIDString}.first?.nickName != nil ? "(\((twitterUsers.filter{$0.userIDString == userIDString}.first!).nickName!))" : "" ).font(.title2)
                                }
                                
                                
                                if isNickNameInputShow {
                                    HStack{
                                        //如果有nickname则在编辑窗内显示当前nickname，否则显示默认的字符"nickname"
                                        
                                        TextField(twitterUsers.filter{$0.userIDString == userIDString}.first?.nickName != nil ? "(\((twitterUsers.filter{$0.userIDString == userIDString}.first!).nickName!))" : "nickname",
                                                  text: $nickNameText)
                                            .frame(width: 100)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        
                                        Button(action: {
                                            
                                            saveOrUpdateTwitterUser()
                                            withAnimation{isNickNameInputShow = false}
                                        }){
                                            Image(systemName: "arrow.forward.circle").foregroundColor(.accentColor).font(.title2)
                                        }.disabled(nickNameText == "")
                                        Spacer()
                                    }
                                } else {
                                    Button(action: {
                                        withAnimation{isNickNameInputShow = true}
                                    }){
                                        Image(systemName: "highlighter").foregroundColor(.gray).font(.title2)
                                    }
                                }
                            }
                            Text(fetchMee.users[userIDString!]?.screenName ?? "ScreenName")
                                .font(.body).foregroundColor(.gray)
                        }
                        Spacer()
                    }.padding(.top, 0)
                    
                    ///用户Bio信息
                    Text(fetchMee.users[userIDString!]?.description ?? "userBio").font(.body)
                        .multilineTextAlignment(.leading)
                        .padding([.top], 16)
                    
                    ///用户位置信息
                    HStack() {
                        Image(systemName: "location.circle").resizable().aspectRatio(contentMode: .fill).frame(width: 12, height: 12, alignment: .center).foregroundColor(.gray)
                        Text(fetchMee.users[userIDString!]?.loc ?? "Unknow").font(.caption).foregroundColor(.gray)
                        Image(systemName: "calendar").resizable().aspectRatio(contentMode: .fill).frame(width: 12, height: 12, alignment: .center).foregroundColor(.gray).padding(.leading, 16)
                        Text(fetchMee.users[userIDString!]?.createdAt ?? "Unknow").font(.caption).foregroundColor(.gray)
                    }.padding(0)
                    
                    ///用户following信息
                    HStack {
                        Text(String(fetchMee.users[userIDString!]?.following ?? 0)).font(.body)
                        Text("Following").font(.body).foregroundColor(.gray)
                        Text(String(fetchMee.users[userIDString!]?.followed ?? 0)).font(.body).padding(.leading, 16)
                        Text("Followers").font(.body).foregroundColor(.gray)
                    }.padding(.bottom, 16)
                }.padding([.leading, .trailing], 16)
                
                ///用户推文部分
                ForEach(self.userTimeline.tweetIDStrings, id: \.self) {
                    tweetIDString in
                    
                    Divider()
                    TweetRow(timeline: self.userTimeline, tweetIDString: tweetIDString)
                }.onDelete(perform: { _ in print(#line, "delete")})
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                HStack {
                    Spacer()
                    Button("More Tweets...") {
                        self.userTimeline.refreshFromButtom(for: userIDString)}
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                } //下方载入更多按钮
            }
            
        }.ignoresSafeArea()
        .onAppear(){
            if self.firstTimeRun {
                self.firstTimeRun = false
//                fetchMee.users[userIDString!]?.id = self.userIDString ?? "0000"
//                fetchMee.users[userIDString!]?.screenName = self.userScreenName
//
//                fetchMee.getUser(userIDString: userIDString!)
                self.userTimeline.refreshFromTop(for: userIDString)
            }
        }
        
    }
}

struct UserInfo_Previews: PreviewProvider {
    static var previews: some View {
        UserInfo(userIDString: "0000")
    }
}

//MARK:-CoreData Operator
extension UserInfo {
    func saveOrUpdateTwitterUser() {
        //检查当前用户如果没有nickName，则新建一个nickName
        
        let currentUser = twitterUsers.filter{$0.userIDString == userIDString}.first ?? TwitterUser(context: viewContext)
        
        currentUser.nickName = nickNameText
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")}
    }
}
