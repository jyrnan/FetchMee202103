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
                   
                   
                    
                    ForEach(viewModel.tweetIDStrings, id: \.self) {tweetIDString in
                        
                        TweetRow(viewModel: viewModel.getTweetViewModel(tweetIDString: tweetIDString, width: proxy.size.width))
                    }
                    .listRowBackground(Color.init("BackGround"))
                        
                        viewModel.detailInfoView
                            .padding(.vertical,16)
                            .frame(height: 100)
                            .listRowBackground(Color.init("BackGround"))
                        
//                    if viewModel.tweetIDStringOfRowToolsViewShowed == nil {
                        Composer(isProcessingDone: $viewModel.isDone, tweetIDString: viewModel.tweetIDString)
                        .frame(height: 42)
                            .listRowBackground(Color.accentColor.opacity(0.4))
//                    }
                    
                   
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
