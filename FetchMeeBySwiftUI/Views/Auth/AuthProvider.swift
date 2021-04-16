//
//  AuthProvider.swift
//  FetchMee
//
//  Created by jyrnan on 2021/4/16.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import AuthenticationServices

class AuthProvider: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
