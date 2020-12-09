//
//  CustomTextEditor.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/27.
//  Copyright © 2020 jyrnan. All rights reserved.
//


//暂时没有使用


import SwiftUI
import UIKit


struct CustomTextEditor: UIViewRepresentable {

    class Coordinator: NSObject, UITextViewDelegate {

        @Binding var text: String
        var didBecomeFirstResponder = false

        init(text: Binding<String>) {
            _text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            self.$text.wrappedValue = textView.text
        }
        
        
    }

    @Binding var text: String
    var isFirstResponder: Bool = false

    func makeUIView(context: UIViewRepresentableContext<CustomTextEditor>) -> UITextView {
        let textView = UITextView(frame: .zero)
        
        textView.font = UIFont.preferredFont(forTextStyle: .body)
                textView.autocapitalizationType = .sentences
                textView.isSelectable = true
                textView.isUserInteractionEnabled = true
        
        textView.delegate = context.coordinator
        return textView
    }

    func makeCoordinator() -> CustomTextEditor.Coordinator {
        return Coordinator(text: $text)
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<CustomTextEditor>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
//            context.coordinator.didBecomeFirstResponder = true
        }
//        else {
//            uiView.resignFirstResponder()
//            context.coordinator.didBecomeFirstResponder = false
//        }
    }
}
