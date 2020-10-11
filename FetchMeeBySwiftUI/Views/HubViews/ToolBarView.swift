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
                          themeColor: .blue)
        case .friends:
            return UIData(label1Text: "Followered:",
                          label2Text: "Following:",
                          label3Text: "more followers added",
                          iconImageName: "person.2.circle.fill",
                          themeColor: .orange)
        }
    }
}



struct ToolBarView: View, Identifiable {
    var id = UUID()
    let type: ToolBarViewType
    @EnvironmentObject var user: User
    @Binding var label1Value: Int?
    @Binding var label2Value: Int?
    @Binding var label3Value: Int?
    
    @State var themeColor: Color = .blue
    
    
    var body: some View {
        ZStack {
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
                            Text(type.uiData.label3Text).bold()
                        }.padding(.bottom, 16).font(.caption).foregroundColor(.gray)
                    }.font(.caption2)
                   
                    Spacer()
                    VStack {
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
            

            
            
            
        }
        
    }
}

//struct ToolBarView_Previews: PreviewProvider {
//
//    static var previews: some View {
////        ToolBarView(type: .tweets ,label1Value: .constant(3), label2Value: .constant(5), label3Value: .constant(5)).environmentObject(User())
//    }
//}
