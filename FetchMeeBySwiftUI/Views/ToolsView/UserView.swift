//
//  UserInfo.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData

struct UserView: View {
    @EnvironmentObject var alerts: Alerts
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TwitterUser.userIDString, ascending: true)]) var twitterUsers: FetchedResults<TwitterUser>
    
    @StateObject var userTimeline: Timeline
    @StateObject var user: User
    
    var userIDString: String? //传入需查看的用户信息的ID
    var userScreenName: String? //传入需查看的用户信息的Name
    
    @State var firstTimeRun: Bool = true //检测用于运行一次
    
    @State var nickNameText: String = ""
    @State var isNickNameInputShow: Bool = false
    
    init(userIDString: String? = nil, userScreenName: String? = nil) {
        self.userIDString = userIDString
        self.userScreenName = userScreenName
        _user = StateObject(wrappedValue: User(userIDString: userIDString ?? "0000", screenName: userScreenName))
        _userTimeline = StateObject(wrappedValue: Timeline(type: .user))
    }
    
    ///自定义返回按钮的范例
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var btnBack : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
    }) {
        HStack {
            Image(systemName: "arrow.backward") // set image here
                .resizable()
                .aspectRatio(contentMode: .fit)
                .font(.body)
                .foregroundColor(.accentColor)
        }
    }
    }
    
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
                
                
                ZStack{
                    Image(uiImage: user.info.banner ?? UIImage(named: "bg")!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        
                        .frame(width:  UIScreen.main.bounds.width - 36, height:150)
                        .cornerRadius(18)
                        .overlay(LinearGradient.init(gradient: Gradient(colors: [Color(UIColor.systemBackground), Color.clear]), startPoint: .init(x: 0.5, y: 0.9), endPoint: .init(x: 0.5, y: 0.4)))

                    
                            ///个人信息大头像
                            Image(uiImage: user.info.avatar ?? UIImage(systemName: "person.circle")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .background(Color.white)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.6), lineWidth: 3))
                                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                    if let im = user.info.avatar {
                                        let imageViewer = ImageViewer(image: im)
                                        alerts.presentedView = AnyView(imageViewer)
                                        withAnimation{alerts.isShowingPicture = true}
                                    }
                                    
                                })
                                .offset(x: 0, y: 65)
                            
                }.padding([.leading, .trailing], 16)
                
               
                
                //用户信息View
                VStack(alignment: .center){

                    VStack(alignment: .center) {
                        HStack {
                            Spacer()
                            Text(user.info.name ?? "Name").font(.body).bold()
                            if !isNickNameInputShow {
                                Text(twitterUsers.filter{$0.userIDString == userIDString}.first?.nickName != nil ? "(\((twitterUsers.filter{$0.userIDString == userIDString}.first!).nickName!))" : "" ).font(.body)
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
                                        Image(systemName: "arrow.forward.circle").foregroundColor(.accentColor).font(.body)
                                    }

                                }
                            } else {
                                Button(action: {
                                    withAnimation{isNickNameInputShow = true}
                                }){
                                    Image(systemName: "highlighter").foregroundColor(.gray).font(.body)
                                }
                            }

                            Spacer()
                        }
                        Text(user.info.screenName ?? "ScreenName")
                            .font(.callout).foregroundColor(.gray)
                    }
                    .padding(.top, 60)
                  
                    ///信封，铃铛和follow按钮
                    HStack{
                       
                        Image(systemName: (self.user.info.notifications == true ? "bell.fill.circle" : "bell.circle")).font(.title2)
                            .foregroundColor(user.info.notifications == true ? .white : .accentColor)
//                            .padding(6)
//                            .background(loingUser.info.notifications == true ? Color.accentColor : Color.clear)
//                            .clipShape(Circle())
//                            .overlay(Circle().stroke(Color.accentColor, lineWidth: 1))
                        if user.info.isFollowing == true {
                            Text("Following")
                                .font(.callout).bold()
                                .frame(width: 84, height: 24, alignment: .center)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .onTapGesture(count: 1, perform: {
                                    user.unfollow(userIDString: userIDString!)
                                })
                        } else {
                            Text("Follow")
                                .font(.callout).bold()
                                .frame(width: 84, height: 24, alignment: .center)
                                .background(Color.primary.opacity(0.1))
                                .foregroundColor(.accentColor)
                                .cornerRadius(12)
                                .onTapGesture(count: 1, perform: {
                                    user.follow(userIDString: userIDString!)
                                })
                        }
                        
                        NavigationLink(destination: ImageGrabView(userIDString: userIDString, userScreenName: userScreenName, timeline: userTimeline)){
                            Image(systemName: "arrow.forward.circle").font(.title2)
                                .foregroundColor(.accentColor)
//
                        }
                        
                    }.padding()

                    ///用户Bio信息
                    Text(user.info.description ?? "userBio").font(.callout)
                        .multilineTextAlignment(.center)
                        .padding([.top], 16)

                    ///用户位置信息
                    HStack() {
                        Image(systemName: "location.circle").resizable().aspectRatio(contentMode: .fill).frame(width: 12, height: 12, alignment: .center).foregroundColor(.gray)
                        Text(user.info.loc ?? "Unknow").font(.caption).foregroundColor(.gray)
                        Image(systemName: "calendar").resizable().aspectRatio(contentMode: .fill).frame(width: 12, height: 12, alignment: .center).foregroundColor(.gray).padding(.leading, 16)
                        Text(user.info.createdAt ?? "Unknow").font(.caption).foregroundColor(.gray)
                    }.padding(0)

                    ///用户following信息
                    HStack {
                        Text(String(user.info.following ?? 0)).font(.callout)
                        Text("Following").font(.callout).foregroundColor(.gray)
                        Text(String(user.info.followed ?? 0)).font(.callout).padding(.leading, 16)
                        Text("Followers").font(.callout).foregroundColor(.gray)
                    }.padding(.bottom, 16)
                }
                .padding([.leading, .trailing], 16)
LazyVStack{
                ///用户推文部分
                ForEach(userTimeline.tweetIDStrings, id: \.self) {
                    tweetIDString in

                    Divider()
                    TweetRow(timeline: userTimeline, tweetIDString: tweetIDString)
                }
                .onDelete(perform: { _ in print(#line, "delete")})
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))

                //下方载入更多按钮
                HStack {
                    Spacer()
                    Button("More Tweets...") {
                        userTimeline.refreshFromBottom(for: userIDString)}
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }
        .navigationTitle(Text(getTitle()))
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: btnBack)
        .onAppear(){
            if self.firstTimeRun {
                self.firstTimeRun = false
                user.getUserInfo()
                userTimeline.refreshFromTop(for: userIDString)
            }
        }
    }
}

//MARK:-CoreData Operator
extension UserView {
    func saveOrUpdateTwitterUser() {
        //检查当前用户如果没有nickName，则新建一个nickName
        
        let currentUser = twitterUsers.filter{$0.userIDString == userIDString}.first ?? TwitterUser(context: viewContext)
        
        ///如果没有输入nick Name，则将该用户的nickName设置成nil
        if nickNameText != "" {
            currentUser.nickName = nickNameText
        } else {
            currentUser.nickName = nil
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError.description)
            //            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            
        }
    }
}

extension UserView {
    func configureBackground() {
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = UIColor.red
        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
    }
    
    
    func getTitle() -> String {
        
        if let title = twitterUsers.filter({$0.userIDString == userIDString}).first?.nickName {
            return title
        } else if let title = user.info.name {
            return title
        } else {
            return "UserName"
        }
    }
}

struct UserInfo_Previews: PreviewProvider {
    static var previews: some View {
        UserView(userIDString: "0000", userScreenName: "name").environmentObject(Alerts()).environmentObject(User())
    }
}
