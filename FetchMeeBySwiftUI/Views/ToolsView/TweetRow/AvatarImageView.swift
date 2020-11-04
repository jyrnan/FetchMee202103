//
//  AvatarImageView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI



struct AvatarImageView: View {
    
    var image: UIImage?
    
    var body: some View {
        Image(uiImage: image ?? UIImage(systemName: "person.circle.fill")!)
            .resizable()
            .aspectRatio(contentMode: .fill)
//            .frame(width: 18, height: 18)
            .clipShape(Circle())
            .overlay(Circle()
             .stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .contentShape(Circle())
    }
}

struct AvataImageView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarImageView(image: UIImage(systemName: "person.circle.fill"))
    }
}
