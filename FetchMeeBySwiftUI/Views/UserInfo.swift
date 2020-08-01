//
//  UserInfo.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct UserInfo: View {
    var userIDString: String?
    @ObservedObject var checkingUser: User = User()
    
    var body: some View {
        VStack {
            Image(uiImage: self.checkingUser.myInfo.banner ?? UIImage(named: "bg")!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
            HStack {
                Image(uiImage: self.checkingUser.myInfo.avatar ?? UIImage(systemName: "person.circle.fill")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 72, height: 72)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .offset(y: -36)
                Spacer()
                Image(systemName: "folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(4)
                    .frame(width: 24, height: 24, alignment: .center)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 1))
                Image(systemName: "folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(4)
                    .frame(width: 24, height: 24, alignment: .center)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 1))
                Text("Following")
                    .font(.caption).bold()
                    .frame(width: 72, height: 24, alignment: .center)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                
            }.padding([.leading, .trailing], 10)
            
            
            Text(self.checkingUser.myInfo.description ?? "userIDString")
                .onAppear(){
                    self.checkingUser.myInfo.id = self.userIDString ?? "0000"
                    self.checkingUser.getMyInfo()
                }
            Spacer()
            
        }
        
    }
}

struct UserInfo_Previews: PreviewProvider {
    static var previews: some View {
        UserInfo()
    }
}

