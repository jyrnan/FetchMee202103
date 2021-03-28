//
//  AvatarImageView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import KingfisherSwiftUI



struct AvatarImageView: View {
    
    var imageUrl: String?
    var placeHolder:Image = Image("LogoWhite").resizable()
    
    
    var body: some View {
        KFImage(URL(string: imageUrl ?? "")).placeholder{placeHolder}
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipShape(Circle())
            .overlay(Circle()
             .stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .contentShape(Circle())
    }
}

struct AvataImageView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarImageView(imageUrl: "")
    }
}
