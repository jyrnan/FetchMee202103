//
//  RetweetMarkView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/28.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct RetweetMarkView: View {
    var userIDString: String?
    var userName: String?
    
    @State var presentedUserInfo: Bool = false
    
    var body: some View {
        HStack {
//            NavigationLink(destination: UserView(userIDString: userIDString), isActive: $presentedUserInfo, label: {EmptyView()})
            Image(systemName:"repeat")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12, alignment: .center)
                .foregroundColor(.gray)
            Text( "\(userName ?? "userName")  retweeted")
                .font(.subheadline).lineLimit(2)
                .foregroundColor(.gray)
                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                    self.presentedUserInfo = true
                })
            Spacer()
        }.offset(x: 44).padding(.top, 0).padding(.bottom, 0)
    }
}

struct RetweetMarkView_Previews: PreviewProvider {
    static var previews: some View {
        RetweetMarkView()
    }
}
