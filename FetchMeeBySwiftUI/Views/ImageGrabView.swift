//
//  ImageGrabView.swift
//  FetchMee
//
//  Created by yoeking on 2020/8/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ImageGrabView: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User //始终是登录用户的信息
    
    var userIDString: String? //传入需查看的用户信息的ID
    var userScreenName: String? //传入需查看的用户信息的Name
    
    @StateObject var checkingUser: User = User()
    @StateObject var userTimeline: Timeline = Timeline(type: .user)
    
    var tweetImages: [UIImage] {
        var tweetImages: [UIImage] = []
        let images = self.userTimeline.imageTweetStrings.map{
            self.userTimeline.tweetMedias[$0]?.images ?? []
        }
        tweetImages = images.flatMap{$0}
        return tweetImages
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 140))
        ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns,spacing: 10) {
            ForEach(self.userTimeline.tweetIDStrings, id: \.self) {idString in
                ForEach(0..<self.userTimeline.tweetMedias[idString]!.images.count) {index in

                if self.userTimeline.tweetMedias[idString]!.images[index] != nil {
                    ImageThumb(timeline: self.userTimeline, tweetIDString: idString, number: index, width: 100, height: 100)
                }
            }
            }
                
            }
            
            HStack {
                Spacer()
                Button("More Tweets...") {
                    self.userTimeline.refreshFromButtom(for: userIDString)}
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            } //下方载入更多按钮
        }
        //TODO: loadmore
    }
}

struct ImageGrabView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGrabView()
    }
}
