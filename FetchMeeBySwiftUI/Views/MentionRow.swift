//
//  MentionRow.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/14.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

struct MentionRow: View {
    var tweetMedia: TweetMedia
    @State var presentedUserInfo: Bool = false
    
    var body: some View {
            HStack(alignment: .center, spacing: 0) {
                Image(uiImage: self.tweetMedia.avatar!)
                    .resizable()
                    .frame(width: 36, height: 36)
                    
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    
                    .padding(.init(top: 4, leading: 0, bottom: 4, trailing: 12))
                    
                    .onTapGesture {
                        self.presentedUserInfo = true
                    }
                    .sheet(isPresented: $presentedUserInfo) {
                        UserInfo()
                    }
                
                Text(self.tweetMedia.tweetText ?? "Some tweet text Some tweet text Some tweet text Some tweet text Some tweet text Some tweet text")
                    .lineLimit(2)
                    .font(.body)
                    .padding(.top, 0)
                    .padding(.bottom, 4)
                
                Spacer()
            }
    }
}


struct MentionRow_Previews: PreviewProvider {
    static var previews: some View {
        MentionRow(tweetMedia: TweetMedia(id: "234343"))
    }
}
