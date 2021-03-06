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
            return UIData(label1Text: "DraftsCout:",
                          label2Text: "LogsCount:",
                          label3Text: "new message.",
                          iconImageName: "paperclip.circle.fill",
                          themeColor: Color("DarkGreen"))
        }
    }
}



struct ToolBarView: View, Identifiable {
    
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
                        .foregroundColor(Color.init("BackGroundLight"))
                    //                        .shadow(color: Color.black.opacity(0.2),radius: 3, x: 0, y: 3)
                    
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
                            return AnyView( BackOfToolsToolBar() )
                        }
                    }
                }
                .frame(height: 76)
                .scaleEffect(x: 1, y: -1, anchor: UnitPoint(x: 0.5, y: 0.5))
            }
        }
        .rotation3DEffect(!self.isFaceUp ? Angle(degrees: 180): Angle(degrees: 0), axis: (x: CGFloat(10), y: CGFloat(0), z: CGFloat(0)))
    }
}

struct ToolBarView_Previews: PreviewProvider {
    static var previews: some View {
        ToolBarView(type: .friends)
    }
}
