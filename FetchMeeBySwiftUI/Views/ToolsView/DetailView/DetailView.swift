//
//  DetailView.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine


struct DetailView: View {
    @ObservedObject var viewModel: DetailViewModel
//    var tweetIDString: String //传入DetailView的初始推文
    
    @State var firstTimeRun: Bool = true //检测用于运行一次
    
    
    var body: some View {

                ScrollView {
                    
                    ForEach(viewModel.tweetIDStrings, id: \.self) {tweetIDString in
                        
                        TweetRow(viewModel: TweetRowViewModel(timeline: viewModel, tweetIDString: tweetIDString, width: 300))
                        Divider()
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading:0, bottom: 0, trailing: 0))
//                    Composer(tweetIDString: viewModel.tweetIDString)
//                        .frame(height: 24)
                    Divider()
                    Spacer()
                }
                .navigationTitle("Detail")
                .onAppear {
                    if self.firstTimeRun {
                        self.firstTimeRun = false
                        viewModel.getReplyDetail(for: viewModel.tweetIDString)
                    } else {print(#line, "firstTimeRun is already true")}} //页面出现时执行一次刷新
                
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(viewModel: DetailViewModel(tweetIDString: "0000"))
    }
}
