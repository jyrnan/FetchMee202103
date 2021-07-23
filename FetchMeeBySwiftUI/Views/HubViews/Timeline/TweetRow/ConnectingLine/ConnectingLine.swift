//
//  ConnectingLine.swift
//  ConnectingLine
//
//  Created by jyrnan on 2021/7/23.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI

struct ConnectingLine: View {
    var offsetFromLeading: CGFloat = 48
    var offsetFromTop: CGFloat = 48
    var opacity: CGFloat = 0
    
    var body: some View {
        GeometryReader {proxy in
            VStack(spacing: 0){
                ForEach(0..<Int((proxy.size.height - offsetFromTop) / 11 - 1)) {index in
                    Circle()
                        .frame(width: 3, height: 3)
                        .padding(4)
                        .foregroundColor(.secondary)
                        .opacity(opacity)
                }
            }
            .frame(width: 2 * offsetFromLeading, height: proxy.size.height - offsetFromTop, alignment: .bottom)
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottomLeading)
        }
    }
}

struct ConnectingLine_Previews: PreviewProvider {
    static var previews: some View {
        ConnectingLine()
            .frame(height: 200)
    }
}
