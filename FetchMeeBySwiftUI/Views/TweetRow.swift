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
    @State var presentedUserInfo: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                //
                HStack(alignment: .top, spacing: 0) {
                    VStack{
                        Image(uiImage: self.tweetMedia.avatar!)
                            .resizable()
                            .frame(width: 36, height: 36)
                            
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            
                            .padding(.init(top: 12, leading: 0, bottom: 12, trailing: 12))
                            
                            .onTapGesture {
                                self.presentedUserInfo = true
                            }
                            .sheet(isPresented: $presentedUserInfo) {
                                UserInfo()
                            }
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
                    }.padding(.trailing, 0)
                        .padding(.bottom, 8)
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
