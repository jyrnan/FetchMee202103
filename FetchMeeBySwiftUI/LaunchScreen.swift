//
//  LaunchScreen.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/17.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Color.init("TwitterBlue")
            Image("LogoWhite")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120, alignment: .center)
                .offset(x: 0, y: -50)
            
        }
        .ignoresSafeArea()
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
