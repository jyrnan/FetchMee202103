//
//  AttributedTextView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/4.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import UIKit


struct NSAttributedStringView: View {
    var viewModel :StatusTextViewModel
    var width: CGFloat
    
    @State var isShowUserView: Bool = false
    @State var userIDString: String = "0000"
    
    var body: some View {
        ZStack{
        NavigationLink(destination: UserView(userIDString: userIDString), isActive: $isShowUserView) {
            EmptyView()}
        self.makeNativeTextView(width: width,attributedText: viewModel.attributedText)
        }
    }
    
    func makeNativeTextView(width: CGFloat, attributedText: NSMutableAttributedString) -> some View {
        let height = attributedText.height(containerWidth: width)
        return NativeTextView(attributedText: attributedText, isShowUserView: $isShowUserView, userIDString: $userIDString, action: showUserView(userIDString:))
            .frame(width: width, height: height)
        
    }
    
    ///
    func showUserView(userIDString: String) -> (){
        self.userIDString = userIDString
        self.isShowUserView = true
    }
}


#if os(iOS)
typealias NativeFont = UIFont
typealias NativeColor = UIColor

struct NativeTextView: UIViewRepresentable {
    
    var attributedText: NSMutableAttributedString
    @Binding var isShowUserView: Bool
    @Binding var userIDString: String
    
    var action: (String) -> ()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(textView: self, isShowUserView: $isShowUserView, userIDString: $userIDString, action: action)
    }
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .all
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.textContainer.lineFragmentPadding = 0
        
        textView.attributedText = attributedText
        
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
    }
    
    
    //增加Coordinator
    class Coordinator: NSObject, UITextViewDelegate {
        let textView: NativeTextView
        
        var isShowUserView: Binding<Bool>
        var userIDString: Binding<String>
        
        var action: (String) -> ()
        
        init(textView: NativeTextView, isShowUserView: Binding<Bool>, userIDString: Binding<String>, action: @escaping (String) -> ()) {
            self.textView = textView
            self.isShowUserView  = isShowUserView
            self.userIDString = userIDString
            self.action = action
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            
            print(#line, #file, "clicked.", characterRange, URL, interaction)
//            UIApplication.shared.open(URL)
//            self.userIDString.wrappedValue = URL.absoluteString
//            self.isShowUserView.wrappedValue = true
            if URL.absoluteString.starts(with: "http") {
                UIApplication.shared.open(URL)
            } else {
                action(URL.absoluteString)}
            return false
        }
        
    }
}

extension NSAttributedString {
    func height(containerWidth: CGFloat) -> CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: containerWidth, height: CGFloat.greatestFiniteMagnitude),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return ceil(rect.size.height)
    }
}
#endif








