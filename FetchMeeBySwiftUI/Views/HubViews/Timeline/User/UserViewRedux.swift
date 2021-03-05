//
//  UserViewRedux.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/27.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation

import SwiftUI
import CoreData
import KingfisherSwiftUI
import Swifter

struct UserViewRedux: View {
    @EnvironmentObject var store:Store
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var twitterUsers: FetchedResults<TwitterUser>
    
    var userTimeline: AppState.TimelineData.Timeline {store.appState.timelineData.timelines[TimelineType.user(userID: userIDString).rawValue]!}
    var userJSON: JSON {UserRepository.shared.users[userIDString] ?? JSON.init("")}
    var user: UserInfo {store.appState.timelineData.requestedUser}
    
    var userIDString: String //传入需查看的用户信息的ID
    
    @State var firstTimeRun: Bool = true //检测用于运行一次
    
    @State var nickNameText: String = ""
    @State var isNickNameInputShow: Bool = false
    
    init(userIDString: String, userScreenName: String? = nil) {
        self.userIDString = userIDString
        
        ///从CoreData里获取用户信息,但是不能立刻打印相应的内容，因为获取需要一定时间，是异步进行
        ///所以此时打印twitterUser的信息是没有的，但是在后续的代码中则可以看到其实已经获取到了相应值
        ///这样做法可以简化CoreData获取的结果，后续代码更加简洁
        let userFetch:NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        userFetch.sortDescriptors = [NSSortDescriptor(keyPath: \TwitterUser.createdAt, ascending: true)]
        userFetch.predicate = NSPredicate(format: "%K = %@", #keyPath(TwitterUser.userIDString), userIDString)
        _twitterUsers = FetchRequest(fetchRequest: userFetch)
        
        
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
        GeometryReader{proxy in
            List {
                ZStack{
                    VStack{
                        KFImage(URL(string: user.bannerUrlString ?? "ok")!).placeholder{Image("bg")}
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width:  UIScreen.main.bounds.width,
                            height:150)
                        .cornerRadius(24)
                        .overlay(LinearGradient.init(gradient: Gradient(colors: [Color.init("BackGround"), Color.clear]), startPoint: .init(x: 0.5, y: 0.9), endPoint: .init(x: 0.5, y: 0.4)))
                        
                        Rectangle().frame(height: 65).foregroundColor(Color.init("BackGround"))
                    }
                    ///个人信息大头像
                    KFImage(URL(string: user.avatarUrlString ?? "ok")!)
                        .placeholder{Image(systemName: "person.circle")}
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.6), lineWidth: 3))
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            
                            
                        })
                        .offset(x: 0, y: 65)
                    
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.init("BackGround"))
                //用户信息View
                VStack(alignment: .center){
                    
                    VStack(alignment: .center) {
                        HStack {
                            Spacer()
                            Text(user.name ?? "Name").font(.body).bold().onTapGesture {
                            }
                            if !isNickNameInputShow {
                                Text(twitterUsers.first?.nickName != nil ? "(\(twitterUsers.first!.nickName!))" : "" ).font(.body)
                            }
                            
                            if isNickNameInputShow {
                                HStack{
                                    //如果有nickname则在编辑窗内显示当前nickname，否则显示默认的字符"nickname"
                                    
                                    TextField(twitterUsers.first?.nickName ?? "nickname",
                                              text: $nickNameText)
                                        .frame(width: 100)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Button(action: {TwitterUser.updateOrSaveToCoreData(from: userJSON, in: viewContext,isLocalUser: false, updateNickName: nickNameText)
                                        
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
                        Text(user.screenName ?? "ScreenName")
                            .font(.callout).foregroundColor(.gray)
                    }
                    .padding(.top, 0)
                    
                    ///信封，铃铛和follow按钮
                    HStack{
                        
                        Image(systemName: (user.notifications == true ? "bell.fill.circle" : "bell.circle")).font(.title2)
                            .foregroundColor(user.notifications == true ? .white : .accentColor)
                        //
                        if "follow" == "follow" {
                            Text("Following")
                                .font(.callout).bold()
                                .frame(width: 84, height: 24, alignment: .center)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .onTapGesture(count: 1, perform: {
//                                    viewModel.unfollow(userIDString: userIDString)
                                })
                        } else {
                            Text("Follow")
                                .font(.callout).bold()
                                .frame(width: 84, height: 24, alignment: .center)
                                .background(Color.primary.opacity(0.1))
                                .foregroundColor(.accentColor)
                                .cornerRadius(12)
                                .onTapGesture(count: 1, perform: {
//                                    viewModel.follow(userIDString: userIDString)
                                })
                        }
                        
                        //                    NavigationLink(destination: ImageGrabView(userIDString: userIDString, userScreenName: userScreenName, timeline: userTimeline)){
                        Image(systemName: "arrow.forward.circle").font(.title2)
                            .foregroundColor(.accentColor)
                    }.padding()
                    
                    ///用户Bio信息
                    NSAttributedStringView(viewModel: StatusTextViewModel(status: userJSON, alignment: .center), width: 300).padding([.top], 16)
                    
                    ///用户位置信息
                    HStack() {
                        Image(systemName: "location.circle").resizable().aspectRatio(contentMode: .fill).frame(width: 12, height: 12, alignment: .center).foregroundColor(.gray)
                        Text(userJSON["location"].string ?? "Unknow").font(.caption).foregroundColor(.gray)
                        Image(systemName: "calendar").resizable().aspectRatio(contentMode: .fill).frame(width: 12, height: 12, alignment: .center).foregroundColor(.gray).padding(.leading, 16)
                        Text( updateTime(createdTime: userJSON["created_at"].string) ).font(.caption).foregroundColor(.gray)
                    }.padding(0)
                    
                    ///用户following信息
                    HStack {
                        Text(String(userJSON["friends_count"].integer ?? 0)).font(.callout)
                        Text("Following").font(.callout).foregroundColor(.gray)
                        Text(String(userJSON["followers_count"].integer ?? 0)).font(.callout).padding(.leading, 16)
                        Text("Followers").font(.callout).foregroundColor(.gray)
                    }.padding(.bottom, 16)
                }
                .listRowBackground(Color.init("BackGround"))
                
   //MARK:-用户推文部分
                    ForEach(userTimeline.tweetIDStrings, id: \.self) {
                        tweetIDString in
                        if tweetIDString != "toolsViewMark" {
                        TweetRow(viewModel: TweetRowViewModel(tweetIDString: tweetIDString, width: proxy.size.width))
                        } }
                    .listRowBackground(Color.init("BackGround"))
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    //下方载入更多按钮
                   
                    HStack {
                        Spacer()
                        Button("More Tweets...") {
                            store.dipatch(.fetchTimeline(timelineType: .user(userID: userIDString), mode: .bottom))
                        }
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                    .listRowBackground(Color.init("BackGround"))
                
                RoundedCorners(color: Color.init("BackGround"), tl: 0, tr: 0, bl: 24, br: 24)
                    .frame(height: 42)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
        
            .navigationTitle(user.name ?? "Name")
        .onAppear(){
            let user = UserInfo(id: userIDString)
            store.dipatch(.userRequest(user: user, isLoginUser: false))
        }
    }
}



extension UserViewRedux {
    func configureBackground() {
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = UIColor.red
        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
        print(#line, "NavigationBar changed.")
    }
    
    func updateTime(createdTime: String?) -> String {
        guard createdTime != nil else {
            return "N/A"
        }
        var result : String = "N/A"
        let timeString = createdTime!
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        if let date = timeFormat.date(from: timeString) {
            let df = DateFormatter()
            df.dateStyle = .short
            df.timeStyle = .none
            
            result = df.string(from: date)
            
        }
        return result
    }
}


