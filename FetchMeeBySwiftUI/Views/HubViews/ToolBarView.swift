//
//  ToolBarView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine

enum ToolBarViewType: String {
    case tweets = "Tweets"
    case friends = "Friends"
    case tools = "Tools"
    
    struct UIData {
        var label1Text: String
        var label2Text: String
        var label3Text: String
        var iconImageName: String
        var themeColor: Color
    }
    
    var uiData: UIData  {
        switch self {
        case .tweets:
            return UIData(label1Text: "Tweets:",
                          label2Text: "Tweets:",
                          label3Text: "tweets posted last 24H",
                          iconImageName: "message.circle.fill",
                          themeColor: Color.init("TwitterBlue"))
        case .friends:
            return UIData(label1Text: "Followered:",
                          label2Text: "Following:",
                          label3Text: "more followers added",
                          iconImageName: "person.2.circle.fill",
                          themeColor: .orange)
        case .tools:
            return UIData(label1Text: "Followered:",
                          label2Text: "Following:",
                          label3Text: "new message.",
                          iconImageName: "paperclip.circle.fill",
                          themeColor: Color("DarkGreen"))
        }
    }
}



struct ToolBarView: View, Identifiable {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetDraft.createdAt, ascending: true)]) var drafts: FetchedResults<TweetDraft>
    
    var isFaceUp: Bool = true //是否正面朝上
    
    var id = UUID()
    let type: ToolBarViewType
    
    var label1Value: Int?
    var label2Value: Int?
    var label3Value: Int?
    
    @State var themeColor: Color = Color.init("TwitterBlue")
    
    
    var body: some View {
        HStack{
            if isFaceUp {
                ZStack{
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(Color.init("BackGroundLight")).shadow(color: Color.black.opacity(0.2),radius: 3, x: 0, y: 3)
                    
                    HStack {
                        Image(systemName: type.uiData.iconImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(type.uiData.themeColor)
                            .frame(width: 40, height: 40, alignment: .center)
                            .padding(16)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack{
                                Text(type.uiData.label1Text)
                                Text("\(label1Value ?? 0)")
                            }.padding(.top, 8).foregroundColor(type.uiData.themeColor)
                            HStack {
                                Text(type.uiData.label2Text)
                                Text("\(label2Value ?? 0)")
                            }.foregroundColor(.gray)
                            Spacer()
                            HStack {
                                Text("\(label3Value ?? 0)")
                                //提示信息
                                Text(type.uiData.label3Text).bold()
                            }.padding(.bottom, 16).font(.caption).foregroundColor(.gray)
                        }.font(.caption2)
                        
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(label3Value ?? 0)").font(.title2).foregroundColor(type.uiData.themeColor)
                            Text(type.rawValue).font(.body).bold()
                                .foregroundColor(Color.init(UIColor.darkGray))
                        }.padding()
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            print(#line)
                        })
                    }
                }
                .frame(height: 76)
                
            } else {
                ZStack{
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(type.uiData.themeColor).shadow(color: Color.black.opacity(0.2),radius: 3, x: 0, y: 3)
                    
                    HStack { () -> AnyView in
                        
                        switch type {
                        case .friends:
                            return AnyView(BackOfFriendToolBar())
                                
                        case .tweets:
                            return AnyView( BackOfTweetsToolBar())
                        
                        case .tools:
                            return AnyView(
                                ScrollView {
                                    ForEach(drafts) { draft in
                                        HStack{
                                            Text(draft.text ?? "pay")
                                                .foregroundColor(.white).font(.caption2).multilineTextAlignment(.leading)
                                            Spacer()
                                            }
                                    }
                                }.padding([.leading, .trailing])
                            )
                        }
                    }
                }
                .frame(height: 76)
                .scaleEffect(x: 1, y: -1, anchor: UnitPoint(x: 0.5, y: 0.5))
            }
        }
        .rotation3DEffect(!self.isFaceUp ? Angle(degrees: 180): Angle(degrees: 0), axis: (x: CGFloat(10), y: CGFloat(0), z: CGFloat(0)))
        .animation(.default) // implicitly applying animation
        
    }
}


struct ToolBarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
        RoundedRectangle(cornerRadius: 16)
            .foregroundColor(Color.blue).shadow(color: Color.black.opacity(0.2),radius: 3, x: 0, y: 3)
        BackOfFriendToolBar().environmentObject(User())
        }.frame(height: 76).padding([.leading, .trailing], 16)
        
        ZStack{
        RoundedRectangle(cornerRadius: 16)
            .foregroundColor(Color.blue).shadow(color: Color.black.opacity(0.2),radius: 3, x: 0, y: 3)
        BackOfTweetsToolBar().environmentObject(User())
        }.frame(height: 76).padding([.leading, .trailing], 16)
    }
}

struct BackOfTweetsToolBar: View {
    @EnvironmentObject var user: User
    
    var body: some View {
        VStack {
            HStack{
                Toggle(isOn: $user.myInfo.setting.isDeleteTweets) {
                    Text("Delete\nAll")
                        .font(.caption).bold()
                        .foregroundColor(.white)
                }
                .alert(isPresented: $user.myInfo.setting.isDeleteTweets, content: {
                                            Alert(title: Text("Delete Tweets?"), message: Text("Delete ALL choosed, it will delete your tweets in background, are you sure?"), primaryButton: .destructive(Text("Sure"), action: {user.myInfo.setting.isDeleteTweets = true}), secondaryButton: .cancel())})
                
                Divider()
                Toggle(isOn: $user.myInfo.setting.isKeepRecentTweets) {
                    Text("Keep\nRecent").font(.caption).bold()
                        .foregroundColor(.white)
                        
                }
            }
            HStack {
                Spacer()
                Text("switch on \"Keep Recent\" to keep recent 80 tweets ")
                    .foregroundColor(.white).font(.caption2)
            }
        }.padding([.leading, .trailing]).fixedSize()
    }
}

struct BackOfFriendToolBar: View {
@EnvironmentObject var user: User
    var body: some View {
        VStack{
            HStack {MentionUserSortedView(mentions: user.mention)}
            HStack {
                Spacer()
                Text("Those who mentioned you mostly")
                    .foregroundColor(.white).font(.caption2)
            }
        }.padding([.leading, .trailing])
    }
}
