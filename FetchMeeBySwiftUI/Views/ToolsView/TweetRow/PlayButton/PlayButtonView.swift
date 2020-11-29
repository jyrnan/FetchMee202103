//
//  PlayButtonView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct PlayButtonView: View {
    var viewModel: PlayButtonViewModel
    
    var body: some View {
        Image(systemName: "play.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 48, height: 48, alignment: .center)
            .foregroundColor(.white).opacity(0.7)
            .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
//                Button(action: {viewModel.downloadVideo()},
//                       label: {
//                        Text("Save Video")
//                    Image(systemName: "folder")
//                })
                ForEach(viewModel.contextMenuButtons, id: \.self) {
                    button in
                    
                }
               
            }/*@END_MENU_TOKEN@*/)
    }
}

struct PlayButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PlayButtonView(viewModel: PlayButtonViewModel(timeline: Timeline(type: .home), url: ""))
            .preferredColorScheme(.dark)
    }
}
