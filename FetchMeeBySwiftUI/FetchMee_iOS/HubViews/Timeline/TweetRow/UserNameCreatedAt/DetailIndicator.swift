//
//  DetailIndicator.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/19.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct DetailIndicator: View {
//    var timeline: TimelineViewModel
//     var tweetIDString: String
    @ObservedObject var viewModel: ToolsViewModel
    
    @State var isUnRead: Bool = true
    
    var body: some View {
        HStack(spacing: 0){
            Spacer()
            Circle()
                .fill(viewModel.retweeted ? Color.green : Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 3)
            Circle()
                .fill(viewModel.favorited ? Color.red : Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 3)
            Circle()
                .fill(isUnRead ? Color.blue : Color.gray)
                .frame(width: 5, height: 5, alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 3)
                .onAppear{
                    ///该视图出现则减少新推文数量1，并设置成已经阅读变量标志，避免重复
                    if isUnRead && (viewModel.timeline.newTweetNumber > 0) {
                        viewModel.timeline.newTweetNumber -= 1
                    }
                    self.delay(delay: 3, closure: {
                        self.isUnRead = false

                    })
                }
            Spacer()
        }
        .frame(width: 27, height: 11, alignment: .center)
        .opacity(0.7)
        .padding(.all, 0)
        .contentShape(Rectangle())
    }
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

struct DetailIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DetailIndicator(viewModel: ToolsViewModel(timeline: Timeline(type: .home), tweetIDString: "0000"))
    }
}
