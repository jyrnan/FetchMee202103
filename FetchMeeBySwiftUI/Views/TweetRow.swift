//
//  TweetRow.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct TweetRow: View {
    var tweetMedia: TweetMedia
    
    var body: some View {
        VStack {
            VStack {
                //
                HStack(alignment: .top, spacing: 0) {
                    VStack{
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 48, height: 48)
                            
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.black, lineWidth: 2))
                            .padding(12)
                            .onTapGesture {
                                
                        }
                    }
                    VStack(alignment: .leading, spacing: 0 ) {
                        
                            HStack {
                                Text(self.tweetMedia.userName ?? "UserName")
                                    .font(.headline)
                                Text(self.tweetMedia.screenName ?? "screenName")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 4)
                        Text(self.tweetMedia.tweetText ?? "Some tweet text")
                            .font(.body)
                    }
                }
            }
        }
    }
}

struct TweetRow_Previews: PreviewProvider {
    static var previews: some View {
        TweetRow(tweetMedia: TweetMedia(id: ""))
    }
}
