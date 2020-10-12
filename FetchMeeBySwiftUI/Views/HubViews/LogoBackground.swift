//
//  LogoBackground.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct LogoBackground: View {
    var body: some View {
        VStack {
            HStack{
                Spacer()
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 220, height: 220, alignment: .center)
                    .opacity(0.1)
                    .ignoresSafeArea()
                
            }
            Spacer()
        }
    }
}
struct LogoBackground_Previews: PreviewProvider {
    static var previews: some View {
        LogoBackground()
    }
}
