//
//  AvatarImageView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Kingfisher



struct AvatarImageView: View {
    
    var imageUrl: String?
    var placeHolder:Image = Image(systemName: "person.circle.fill").resizable()
    var isFavoriteUser: Bool = false
    
    var body: some View {
        KFImage(URL(string: imageUrl ?? "")).placeholder{placeHolder}
//        RemoteImage(imageUrl: imageUrl ?? "")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipShape(Circle())
            .overlay(Circle().stroke(isFavoriteUser ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isFavoriteUser ? 2 : 1))
            .contentShape(Circle())
    }
}

struct AvataImageView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarImageView(imageUrl: "", isFavoriteUser: true)
            .frame(width: 64, height: 64, alignment: .center)
    }
}
