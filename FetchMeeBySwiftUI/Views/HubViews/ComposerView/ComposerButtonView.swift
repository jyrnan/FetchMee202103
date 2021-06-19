//
//  ComposerButtonView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/16.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ComposerButtonView: View {
    @Binding var tweetText: String
    
    var body: some View {
        VStack {
            Spacer()
        HStack{
            Spacer()
            NavigationLink(
                destination: ComposerOfHubView(swifter: Store().fetcher.swifter, tweetText: self.$tweetText, isUsedAlone: true )) {
            Image(uiImage: UIImage(named: "Logo")!)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 40, height: 40, alignment: .center)
            .foregroundColor(.accentColor)
                .background(Circle().frame(width: 48, height: 48, alignment: .center).foregroundColor(Color.init("BackGround")).opacity(0.8))
            .padding(.trailing, 24)
            }
        }
       
        }
    }
}

struct ComposerButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ComposerButtonView(tweetText: .constant("Tweet"))
        }
    }
}
