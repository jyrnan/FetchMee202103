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
    
    let themeColor = UIColor(ThemeColor(rawValue: (userDefault.object(forKey: "themeColor") as? String) ?? "blue")!.color)
    //
    
    init(status: JSON) {
        self.status = status
        attributedText = setAttributedText()
    }
    
    func setAttributedText() -> NSMutableAttributedString{
        let text = status["text"].string ??  status["description"].string!
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
        
        attributedString = setHashTagAttribute(status: status, attributedString: attributedString)
        attributedString = setMentionAttribute(status: status, attributedString: attributedString)
        
        return attributedString
    }
    
    func setHashTagAttribute(status: JSON, attributedString: NSMutableAttributedString) -> NSMutableAttributedString {
        guard let hashTags = status["entities"]["hashtags"].array, !hashTags.isEmpty else {return attributedString}
        
        let hashTagAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: themeColor] as [NSAttributedString.Key : Any]
        
        for hashTag in hashTags {
            if let begin: Int = hashTag["indices"].array?.first?.integer,
               let end: Int = hashTag["indices"].array?.last?.integer {
                let range: NSRange = NSRange(location: begin, length: end - begin)
                attributedString.addAttributes(hashTagAttribute, range: range)
            }
        }
        return attributedString
    }
    
    func setMentionAttribute(status: JSON, attributedString: NSMutableAttributedString) -> NSMutableAttributedString {
        guard let user_mentions = status["entities"]["user_mentions"].array, !user_mentions.isEmpty else {return attributedString}
        
        let mentionsAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: themeColor] as [NSAttributedString.Key : Any]
        
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
        
        guard attributedString.string.first == "@" else {return attributedString}
        
        let replyingToprefix = NSMutableAttributedString(string: "Replying to ")
        let range = NSMakeRange(0, replyingToprefix.string.count)
        replyingToprefix.addAttribute(.foregroundColor, value: UIColor.gray, range: range)
        replyingToprefix.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range: range)
        
        attributedString.insert(replyingToprefix, at: 0)
        
        return attributedString
    }
}
