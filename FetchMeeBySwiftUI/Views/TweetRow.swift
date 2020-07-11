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
    @ObservedObject var timeline: Timeline
    
    var idString: String
    
    var body: some View {
        VStack {
            VStack {
                //
                HStack(alignment: .top, spacing: 0) {
                    VStack{
                        Group {
//                            if self.timeline.tweetMedias[idString]?.avatar != nil {
//                                Image(uiImage: (self.timeline.tweetMedias[idString]?.avatar!)!)
//                                    .resizable()
//                                    .frame(width: 48, height: 48)
//
//                                    .clipShape(Circle())
//                                    .overlay(
//                                        Circle().stroke(Color.black, lineWidth: 2))
//                                    .padding(12)
//                            } else {
                            Image(uiImage: ((self.timeline.tweetMedias[idString]?.avatar ?? UIImage(systemName: "person.fill"))!))
                                .resizable()
                                .frame(width: 48, height: 48)
                                
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color.black, lineWidth: 2))
                                .padding(12)
                            
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 0 ) {
                        Button("Test", action: {
                            print(#line)
                            print(#line, self.timeline.tweetMedias[self.idString]?.avatar)
                            self.timeline.tweetMedias[self.idString]?.userName = "OK"
                            self.timeline.tweetMedias[self.idString]?.avatar = UIImage(systemName: "folder")
                            print(#line, self.timeline.tweetMedias[self.idString]?.avatar)
                        })
                            HStack {
                                
                                Text(self.timeline.tweetMedias[idString]?.userName ?? "UserName")
                                    .font(.headline)
                                Text("@" + (self.timeline.tweetMedias[idString]?.screenName ?? "screenName"))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 4)
                        Text(self.timeline.tweetMedias[idString]?.tweetText ?? "Some tweet text")
                            .font(.body)
                    }
                }
            }
        }
    }
}

struct TweetRow_Previews: PreviewProvider {
    static var previews: some View {
//        TweetRow(tweetMedia: TweetMedia(id: ""))
        Text("hello")
    }
}
