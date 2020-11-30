//
//  TestNavi.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/17.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct TestNavi: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: SettingView()){
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)}
        }
    }
}

struct TestNavi_Previews: PreviewProvider {
    static var previews: some View {
        TestNavi()
    }
}
