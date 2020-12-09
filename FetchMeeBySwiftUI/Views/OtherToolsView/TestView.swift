//
//  TestView.swift
//  FetchMee
//
//  Created by jyrnan on 11/4/20.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct TestView: View {
    @StateObject var timeline = Timeline(type: .home)
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
