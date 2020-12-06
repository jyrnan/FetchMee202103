//
//  AttributedTextView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/4.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI


struct NSAttributedStringView: View {
    var viewModel :StatusTextViewModel
    var width: CGFloat

    var body: some View {
        NSAttributedStringView.makeNativeTextView(width: width,attributedText: viewModel.attributedText)
    }
    
    static func makeNativeTextView(width: CGFloat, attributedText: NSMutableAttributedString) -> some View {
            let height = attributedText.height(containerWidth: width)
        return NativeTextView(attributedText: attributedText)
            .frame(width: width, height: height)
    }
}


#if os(iOS)
typealias NativeFont = UIFont
typealias NativeColor = UIColor

struct NativeTextView: UIViewRepresentable {
        var attributedText: NSMutableAttributedString
        func makeUIView(context: Context) -> UITextView {
                let textView = UITextView()
                textView.isEditable = false
                textView.isScrollEnabled = false
            textView.dataDetectorTypes = .link
                textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                textView.textContainer.lineFragmentPadding = 0
                
                textView.attributedText = attributedText
                return textView
        }
        func updateUIView(_ textView: UITextView, context: Context) {
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

/// 采用ULLabel
//struct TextWithAttributedString: UIViewRepresentable {
//    var width: CGFloat
//    var attributedText:NSMutableAttributedString
//
//    func makeUIView(context: Context) -> UILabel {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.lineBreakMode = .byWordWrapping
//
//        return label
//    }
//
//    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<TextWithAttributedString>) {
//
//        uiView.preferredMaxLayoutWidth = width
//        uiView.attributedText = attributedText
//    }
//}


#endif








