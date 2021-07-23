//
//  AvatarImageView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/13.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI



struct AvatarImageView: View {
    
    var imageUrl: String
    var placeHolder:Image = Image(systemName: "person.circle.fill").resizable()
    var hasNickname: Bool = false
    
    var body: some View {
        AsyncImage(url: URL(string: imageUrl)){phase in
            switch phase {
            case .empty:
                Image(systemName: "person.circle.fill")
                    .resizable().scaledToFill().foregroundColor(.secondary)
            case .success(let image) :
                image.resizable().scaledToFill()
            case .failure: // if failed, one more time again😳
                AvatarImageView(imageUrl: imageUrl, hasNickname: hasNickname)
                @unknown default:
                EmptyView()
            }
        }
        
//        RemoteImage(imageUrl: imageUrl)
//            .aspectRatio(contentMode: .fill)
            
            .clipShape(Circle())
            .overlay(Circle().stroke(hasNickname ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: hasNickname ? 2 : 1))
            .contentShape(Circle())
    }
}

struct AvataImageView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarImageView(imageUrl: "", hasNickname: true)
            .frame(width: 64, height: 64, alignment: .center)
    }
}
