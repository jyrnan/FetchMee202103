//
//  SafariView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/30.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import SafariServices
import Combine
import UIKit

struct SafariView: UIViewControllerRepresentable {
    
    @Binding var url: URL
    
    typealias UIViewControllerType = SFSafariViewController
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariVC = SFSafariViewController(url: url)
        return safariVC
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        print(#line)
    }
    
}

struct SafariView_Previews: PreviewProvider {
    static var previews: some View {
        SafariView(url: .constant(URL(string: "https://www.twitter.com")!))
    }
}
