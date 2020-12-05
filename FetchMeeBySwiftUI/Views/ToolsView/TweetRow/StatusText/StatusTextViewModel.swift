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
        paragraphStyle.paragraphSpacing = 8
            let range = NSMakeRange(0, (string as NSString).length)
            attributedString.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range: range)
            attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: range)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
            
//        guard let user_mentions = status["entities"]["user_mentions"].array, !user_mentions.isEmpty else {return attributedString}
        
//        let mentionsAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.orange] as [NSAttributedString.Key : Any]
//
//        for user_mention in user_mentions {
//            if let begin: Int = user_mention["indices"].array?.first?.integer,
//               let end: Int = user_mention["indices"].array?.last?.integer {
//                let range: NSRange = NSRange(location: begin, length: end - begin)
//                attributedString.addAttribute(.foregroundColor, value: UIColor.init(named: "TwitterBlue"), range: range)
//            }
//
//        }
            attributedString = setMentionAttribute(status: status, attributedString: attributedString)
        
            
        
            return attributedString
    }
    
    func setMentionAttribute(status: JSON, attributedString: NSMutableAttributedString) -> NSMutableAttributedString {
        guard let user_mentions = status["entities"]["user_mentions"].array, !user_mentions.isEmpty else {return attributedString}
        
        let mentionsAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.init(named: "TwitterBlue")] as [NSAttributedString.Key : Any]
        
        ///设置一个换行初始位置
        var wrapPosition = 0
        
        for user_mention in user_mentions {
            if let begin: Int = user_mention["indices"].array?.first?.integer,
               let end: Int = user_mention["indices"].array?.last?.integer {
                let range: NSRange = NSRange(location: begin, length: end - begin)
                attributedString.addAttributes(mentionsAttribute, range: range)
                
                if checkWrapPositionOfText(status: status, indice: end) {
                    wrapPosition = end
                }
            }
        }
        
        attributedString.replaceCharacters(in: NSRange(location: wrapPosition, length: 1), with: "\n")
        
        let prefixedAttributedString = addReplyingToPrefix(attributedString: attributedString)
        
        return prefixedAttributedString
    }
    
    func checkWrapPositionOfText(status: JSON, indice: Int) -> Bool{
        
        ///这里增加一个indice的判断，避免mention用户名出现在statusText的末位的情况
        ///否则会出现读取indice后一个字符时候出现越界情况
        guard let statusText = status["text"].string, indice != statusText.count else {return false}
        
        let index = statusText.index(statusText.startIndex, offsetBy: indice + 1)
        return statusText[index] != "@"
}
    
    func addReplyingToPrefix(attributedString: NSMutableAttributedString) -> NSMutableAttributedString {
        
        let replyingToprefix = NSMutableAttributedString(string: "Replying to ")
        let range = NSMakeRange(0, replyingToprefix.string.count)
        replyingToprefix.addAttribute(.foregroundColor, value: UIColor.gray, range: range)
        replyingToprefix.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range: range)
        
        attributedString.insert(replyingToprefix, at: 0)
        
        return attributedString
    }
}
