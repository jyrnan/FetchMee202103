//
//  UserNameView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct UserNameView: View {
    var userName: String
    var screenName: String
    var body: some View {
        HStack{
        Text(userName)
            .font(.headline)
            .foregroundColor(.primary)
            .lineLimit(1)
        Text("@" + screenName)
            .font(.subheadline)
            .foregroundColor(.gray)
            .lineLimit(1)
        }
    }
}

struct UserNameView_Previews: PreviewProvider {
    static var previews: some View {
        UserNameView(userName: "Name", screenName: "ScreenName")
    }
}
