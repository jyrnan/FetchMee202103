//
//  StatusTextViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/4.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import UIKit
import Swifter

class StatusTextViewModel: ObservableObject {
    var status: JSON
    var attributedText: NSMutableAttributedString!
    
    init(status: JSON) {
        self.status = status
        attributedText = setAttributedText()
    }
    
    func setAttributedText() -> NSMutableAttributedString{
        let text = status["text"].string!
        let attributedText = attributedString(for: text)
        return attributedText as! NSMutableAttributedString
    }
    
    func attributedString(for string: String) -> NSAttributedString {
            let attributedString = NSMutableAttributedString(string: string)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            let range = NSMakeRange(0, (string as NSString).length)
            attributedString.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range: range)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
            
        let mentionsAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.label] as [NSAttributedString.Key : Any]
        attributedString.addAttributes(mentionsAttribute, range: range)
            return attributedString
    }

}
