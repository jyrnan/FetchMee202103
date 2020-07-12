//
//  TweetRow.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/11.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

struct TweetRow: View {
    var tweetMedia: TweetMedia
    
    var body: some View {
        VStack {
            VStack {
                //
                HStack(alignment: .top, spacing: 0) {
                    VStack{
                        Image(uiImage: self.tweetMedia.avatar!)
                            .resizable()
                            .frame(width: 48, height: 48)
                            
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.gray, lineWidth: 1))
                            .padding(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 0 ) {
                        
                        HStack {
                            
                            Text(self.tweetMedia.userName ?? "UserName")
                                .font(.headline)
                                .lineLimit(1)
                            Text("@" + (self.tweetMedia.screenName ?? "screenName"))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.top, 4)
                        HStack {
                            Text(self.tweetMedia.tweetText ?? "Some tweet text")
                                .lineLimit(nil)
                                .font(.body)
                                .padding(.top, 8)
                                .padding(.bottom, 8)
                        }
                        
                        if tweetMedia.images.count != 0 {
//                            Image(uiImage: self.tweetMedia.images["0"]!)
                            Images(images: self.tweetMedia.images)
//                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 160)
                                .clipped()
                                .cornerRadius(16)
                                
                        }
                    }.padding(.trailing, 16)
                        .padding(.bottom, 16)
                }
            }
        }
    }
}


struct TweetRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TweetRow(tweetMedia: TweetMedia(id: "1334553"))
        
    }
}
