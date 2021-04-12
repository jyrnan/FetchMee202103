//
//  AuthViewController.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/19.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import Swifter
import SwiftUI
import AuthenticationServices

class AuthViewController: UIViewController, SFSafariViewControllerDelegate {
    
    var store: Store!

    @IBAction func login(_ sender: Any) {
        self.store.dipatch(.login(presentingFrom: self, loginUser: nil))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// This is need for ASWebAuthenticationSession
@available(iOS 13.0, *)
extension AuthViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }
}
