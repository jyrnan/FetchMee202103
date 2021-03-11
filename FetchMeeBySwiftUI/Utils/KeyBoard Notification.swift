//
//  KeyBoard Notification.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/26.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine

extension Publishers {
    // 1.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // 2.
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        // 3.
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

// 下面其实是一个接收通知的范例用法
struct ContentView2: View {
    @State private var text = ""
    // 1.
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        VStack {
            Spacer()
            
            TextField("Enter something", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
        // 2.
        .padding(.bottom, keyboardHeight)
        // 3.
        .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
    }
}
