//
//  AttributedTextView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/4.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import UIKit
import SafariServices


struct NSAttributedStringView: View {
    @Environment(\.openURL) var openURL
    
    var attributedText: NSMutableAttributedString
    var width: CGFloat
    
    @State var isShowUserView: Bool = false
    @State var url: URL = URL(string:"https://twitter.com")!
    @State var isShowSafariView: Bool = false
    
    var body: some View {
        ZStack{
            NavigationLink(destination: UserViewRedux(userIDString: url.absoluteString), isActive: $isShowUserView) {
                EmptyView()
                .sheet(isPresented: $isShowSafariView) {SafariView(url: $url)}.disabled(true)
            }.disabled(true).opacity(0.1)
        self.makeNativeTextView(width: width,attributedText: attributedText)
        }
    }
    
    func makeNativeTextView(width: CGFloat, attributedText: NSMutableAttributedString) -> some View {
        let height = attributedText.height(containerWidth: width)
        return NativeTextView(attributedText: attributedText, isShowUserView: $isShowUserView, url: $url, action: urlAction(url:))
            .frame(width: width, height: height)
        
    }
    
    func urlAction(url: URL) -> (){
        self.url = url
        if url.absoluteString.starts(with: "http") {
            self.isShowSafariView = true
        } else if  (url.absoluteString.first(where: {"0123456789".contains($0)}) != nil){
        self.isShowUserView = true
        } else {
            openURL(url)
        }
    }
}


#if os(iOS)
typealias NativeFont = UIFont
typealias NativeColor = UIColor

struct NativeTextView: UIViewRepresentable {
    
    var attributedText: NSMutableAttributedString
    @Binding var isShowUserView: Bool
    @Binding var url: URL
    
    var action: (URL) -> ()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(textView: self, isShowUserView: $isShowUserView, url: $url, action: action)
    }
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .init()
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
        var url: Binding<URL>
        
        var action: (URL) -> ()
        
        init(textView: NativeTextView, isShowUserView: Binding<Bool>, url: Binding<URL>, action: @escaping (URL) -> ()) {
            self.textView = textView
            self.isShowUserView  = isShowUserView
            self.url = url
            self.action = action
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            
            print(#line, #file, "clicked.", characterRange, URL, interaction)

                action(URL)
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
