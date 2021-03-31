//
//  BackOfToolsToolBar.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/16.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine

struct BackOfToolsToolBar: View {
  
    var body: some View {
        LogMessageSmallView().padding(4)

    }
}

struct BackOfToolsToolBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(.blue).shadow(color: Color.black.opacity(0.2),radius: 3, x: 0, y: 3).frame(height: 76)
            BackOfToolsToolBar()
        }
    }
}

