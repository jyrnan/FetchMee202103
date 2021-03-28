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

class AuthViewController: UIViewController, SFSafariViewControllerDelegate {
    
    var store: Store!
    
    let alertTitle = "\"FetchMee\" Wants to Use \"Twitter.com\" to Sign In"
    let alertMessage = "This allows the app and website to share information about you"
    
    @IBAction func login(_ sender: Any) {
        presentAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func presentAlert() {
        let alert = UIAlertController(title: alertTitle,
                                      message: alertTitle,
                                      preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Continue", comment: "Default action"),
                          style: .default,
                          handler: { _ in
                            self.store.dipatch(.login(presentingFrom: self, loginUser: nil))}))
        alert.addAction(
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

 
}
