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
    @StateObject var viewModel: DetailViewModel
    var tweetIDString: String //传入DetailView的初始推文
    
    @State var firstTimeRun: Bool = true //检测用于运行一次
    
    init(tweetIDString: String) {
        self.tweetIDString = tweetIDString
        _viewModel = StateObject(wrappedValue: DetailViewModel(tweetIDString: tweetIDString))
    }
    
    var body: some View {
        GeometryReader{proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                    RoundedCorners(color: Color.init("BackGround"), tl: 24, tr: 24 ).frame(height: 24)
                    
                    ForEach(viewModel.tweetIDStrings, id: \.self) {tweetIDString in
                        
                        TweetRow(viewModel: viewModel.getTweetViewModel(tweetIDString: tweetIDString, width: proxy.size.width))
                        Divider()
                    }
                    
                    if viewModel.tweetIDStringOfRowToolsViewShowed == nil {
                        Divider()
                        Composer(isProcessingDone: $viewModel.isDone, tweetIDString: viewModel.tweetIDString)
                        .frame(height: 36)
                        Divider()
                    }
                    RoundedCorners(color: Color.init("BackGround"), bl: 24, br: 24 ).frame(height: 24)
                    Spacer()
                    }
                }
                .navigationTitle("Detail")
//                .onAppear {
//                    if self.firstTimeRun {
//                        self.firstTimeRun = false
//                        viewModel.getReplyDetail(for: viewModel.tweetIDString)
//                    } else {print(#line, "firstTimeRun is already true")}} //页面出现时执行一次刷新
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(tweetIDString: "0000")
    }
}
