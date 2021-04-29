//
//  UserInfo.swift
//  FetchMee
//
//  Created by jyrnan on 2021/4/4.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import Kingfisher

struct UserInfo: View {
    @EnvironmentObject var store: Store
    var user: User
    var width: CGFloat
    
    @State var nickNameText: String = ""
    @State var isNickNameInputShow: Bool = false
    
    var body: some View {
//        VStack{
        ZStack{
            VStack(spacing: 0){
                KFImage(URL(string: user.bannerUrlString))
                    .placeholder{Image("bg").resizable()}
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height:150)
                    .cornerRadius(24)
                    .overlay(LinearGradient.init(gradient: Gradient(colors: [Color.init("BackGround"), Color.clear]), startPoint: .init(x: 0.5, y: 0.9), endPoint: .init(x: 0.5, y: 0.4)))
                
                Rectangle().frame(height: 65).foregroundColor(Color.init("BackGround"))
            }
            ///个人信息大头像
            KFImage(URL(string: user.avatarUrlString))
                .placeholder{Image("LogoWhite").resizable()}
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.6), lineWidth: 3))
                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                    print(#line, #file, user.bannerUrlString)
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
                    Text(user.name).font(.body).bold().onTapGesture {
                    }
                    if !isNickNameInputShow && user.nickName != nil {
                        Text(" (\(user.nickName!))").font(.body).foregroundColor(.accentColor)
                    }
                    
                    if isNickNameInputShow {
                        HStack{
                            //如果有nickname则在编辑窗内显示当前nickname，否则显示默认的字符"nickname"
                            
                            TextField(user.nickName ?? "nickname",
                                      text: $nickNameText)
                                .frame(width: 100)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                store.repository.users[user.id] =
                                    UserCD.updateOrSaveToCoreData(id: user.id,
                                                              updateNickName: nickNameText)
                                    .convertToUser()
                                
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
                Text(user.screenName )
                    .font(.callout).foregroundColor(.gray)
            }
            .padding(.top, 0)
            
            ///信封，铃铛和follow按钮
            HStack{
                
                Image(systemName: (user.notifications == true ? "bell.fill.circle" : "bell.circle")).font(.title2)
                    .foregroundColor(user.notifications == true ? .white : .accentColor)
                //
                if user.isFollowing == true {
                    Text("Following")
                        .font(.callout).bold()
                        .frame(width: 84, height: 24, alignment: .center)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .onTapGesture(count: 1, perform: {
                        })
                } else {
                    Text("Follow")
                        .font(.callout).bold()
                        .frame(width: 84, height: 24, alignment: .center)
                        .background(Color.primary.opacity(0.1))
                        .foregroundColor(.accentColor)
                        .cornerRadius(12)
                        .onTapGesture(count: 1, perform: {
                        })
                }
                
                //                    NavigationLink(destination: ImageGrabView(userIDString: userIDString, userScreenName: userScreenName, timeline: userTimeline)){
                Image(systemName: "arrow.forward.circle").font(.title2)
                    .foregroundColor(.accentColor)
            }.padding()
            
            ///用户Bio信息
            //                    NSAttributedStringView(attributedText: user.getAttributedText(alignment: .center) , width: 300).padding([.top], 16)
            Text(user.bioText )
            
            ///用户位置信息
            HStack() {
                Image(systemName: "location.circle").resizable().aspectRatio(contentMode: .fill).frame(width: 12, height: 12, alignment: .center).foregroundColor(.gray)
                Text(user.loc ?? "Unknow").font(.caption).foregroundColor(.gray)
                Image(systemName: "calendar").resizable().aspectRatio(contentMode: .fill).frame(width: 12, height: 12, alignment: .center).foregroundColor(.gray).padding(.leading, 16)
                Text( user.createdAt.description ).font(.caption).foregroundColor(.gray)
            }.padding(0)
            
            ///用户following信息
            HStack {
                Text(String(user.following )).font(.callout)
                Text("Following").font(.callout).foregroundColor(.gray)
                Text(String(user.followed )).font(.callout).padding(.leading, 16)
                Text("Followers").font(.callout).foregroundColor(.gray)
            }.padding(.bottom, 16)
        }
        .listRowBackground(Color.init("BackGround"))
//        }
    }
}

struct UserInfo_Previews: PreviewProvider {
    static var previews: some View {
        List{
            UserInfo(user: User(), width: 300)}
    }
}
