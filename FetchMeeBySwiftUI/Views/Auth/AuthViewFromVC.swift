//
//  AuthViewFromVC.swift
//  FetchMee
//
//  Created by jyrnan on 2021/3/28.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI


struct AuthViewFromVC: UIViewControllerRepresentable {
    
    @EnvironmentObject var store: Store
    
    func makeUIViewController(context: Context) -> AuthViewController {
        let authViewController = AuthViewController()
        authViewController.store = store
        return authViewController
    }
    
    func updateUIViewController(_ uiViewController: AuthViewController, context: Context) {
        print(#line)
    }
   
}
