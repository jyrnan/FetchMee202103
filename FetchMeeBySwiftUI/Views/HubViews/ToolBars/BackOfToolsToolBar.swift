//
//  BackOfToolsToolBar.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/16.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct BackOfToolsToolBar: View {
    @EnvironmentObject var user: User
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                VStack{
                    Image(systemName: "message.circle.fill").font(.title2)
                    Text("SayHello").font(.caption).padding(.top, 1)
                }
            })
            Spacer()
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                VStack{
                    Image(systemName: "heart.fill").font(.title2)
                    Text("LikeYou").font(.caption).padding(.top, 1)
                    }
            })
            
            Spacer()
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                VStack{
                    Image(systemName: "sun.max.fill").font(.title2)
                    Text("Morning").font(.caption).padding(.top, 1)
                    }
            })
            
            Spacer()
            
            NavigationLink(destination: UserMarkManageView()){
                VStack{
                    Image(systemName: "person.fill.questionmark").font(.title2)
                    Text("UserMark").font(.caption).padding(.top, 1)
                    }
            }
            
            Spacer()
            
        }.foregroundColor(.white)
        .padding()
    }
}

struct BackOfToolsToolBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(.blue).shadow(color: Color.black.opacity(0.2),radius: 3, x: 0, y: 3).frame(height: 76)
            BackOfToolsToolBar()
        }
    }
}
