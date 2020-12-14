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
                List {
                   
                    RoundedCorners(color: Color.init("BackGround"), tl: 24, tr: 24, bl: 0, br: 0)
                        .frame(height: 42)
                        .foregroundColor(Color.init("BackGround"))
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    ForEach(viewModel.tweetIDStrings, id: \.self) {tweetIDString in
                        
                        TweetRow(viewModel: viewModel.getTweetViewModel(tweetIDString: tweetIDString, width: proxy.size.width))
                    }
                    .listRowBackground(Color.init("BackGround"))
                        
                        viewModel.detailInfoView
                            .padding(.vertical,16)
                            .frame(height: 100)
                            .listRowBackground(Color.init("BackGround"))
                        
                        Composer(isProcessingDone: $viewModel.isDone, tweetIDString: viewModel.tweetIDString)
                        .frame(height: 42)
                            .listRowBackground(Color.accentColor.opacity(0.4))
                   
                    RoundedCorners(color: Color.init("BackGround"), tl: 0, tr: 0, bl: 24, br: 24)
                        .frame(height: 64)
                        .foregroundColor(Color.init("BackGround"))
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                   
                }
                .listRowBackground(Color.init("BackGround"))
                .navigationTitle("Detail")
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(tweetIDString: "0000")
    }
}
