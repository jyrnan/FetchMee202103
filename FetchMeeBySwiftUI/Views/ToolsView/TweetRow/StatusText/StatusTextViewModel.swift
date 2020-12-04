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
            var attributedString = NSMutableAttributedString(string: string)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            let range = NSMakeRange(0, (string as NSString).length)
            attributedString.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range: range)
            attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: range)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
            
        guard let user_mentions = status["entities"]["user_mentions"].array, !user_mentions.isEmpty else {return attributedString}
        
        let mentionsAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.orange] as [NSAttributedString.Key : Any]
        
        for user_mention in user_mentions {
            if let begin: Int = user_mention["indices"].array?.first?.integer,
               let end: Int = user_mention["indices"].array?.last?.integer {
                let range: NSRange = NSRange(location: begin, length: end - begin)
                attributedString.addAttribute(.foregroundColor, value: UIColor.init(named: "TwitterBlue"), range: range)
            }
            
        }
        
            return attributedString
    }
    
    func setMentionAttribute(status: JSON, attributedString: NSMutableAttributedString) -> NSMutableAttributedString {
        guard let user_mentions = status["entities"]["user_mentions"].array, !user_mentions.isEmpty else {return NSMutableAttributedString(string: "")}
        
        let mentionsAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.orange] as [NSAttributedString.Key : Any]
        
        for user_mention in user_mentions {
            if let begin: Int = user_mention["indices"].array?.first?.integer,
               let end: Int = user_mention["indices"].array?.last?.integer {
                let range: NSRange = NSRange(location: begin, length: end - begin)
                attributedString.addAttributes(mentionsAttribute, range: range)
            }
            
        }
        
        return attributedString
    }

}
