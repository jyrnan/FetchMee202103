//
//  FavoriteStarMarkView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/28.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct FavoriteStarMarkView: View {
    var body: some View {
        GeometryReader { geometry in
            Image(systemName: "star.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.size.width * 0.3 , height: geometry.size.height * 0.3, alignment: .center)
                .foregroundColor(.accentColor)
                .background(Circle().foregroundColor(.white).scaleEffect(0.9))

                .offset(x: geometry.size.width * 0.7, y: geometry.size.height * 0.7)
        }
    }
}

struct FavoriteStarMarkView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteStarMarkView()
            .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .center)
            .background(Circle())
    }
}
