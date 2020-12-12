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
//        paragraphStyle.paragraphSpacing = 8
//        paragraphStyle.alignment = NSTextAlignment.center
        let range = NSMakeRange(0, (string as NSString).length)
        attributedString.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range: range)
        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: range)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        
        attributedString = setHashTagAttribute(status: status, attributedString: attributedString)
        attributedString = setLinkAttribute(status: status, attributedString: attributedString)
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
    
    func setLinkAttribute(status: JSON, attributedString: NSMutableAttributedString) -> NSMutableAttributedString {
        guard let urls = status["entities"]["urls"].array, !urls.isEmpty else {return attributedString}
        
        let urlAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: themeColor] as [NSAttributedString.Key : Any]
        
        for url in urls {
            if let begin: Int = url["indices"].array?.first?.integer,
               let end: Int = url["indices"].array?.last?.integer {
                let range: NSRange = NSRange(location: begin, length: end - begin)
                attributedString.addAttributes(urlAttribute, range: range)
                
                ///增加点击功能
                let url = url["expanded_url"].string!
                attributedString.addAttribute(NSAttributedString.Key.link, value: url, range: range)
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
                
                ///增加点击功能
                let userIDString = user_mention["id_str"].string!
                attributedString.addAttribute(NSAttributedString.Key.link, value: userIDString, range: range)
                
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
    
    
    /// 给最终的字串增加一个ReplyingTo的前缀
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

//MARK:-参考
class ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let text = NSMutableAttributedString(string: "Already have an account? ")
        text.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 12), range: NSMakeRange(0, text.length))

        let selectablePart = NSMutableAttributedString(string: "Sign in!")
        selectablePart.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 12), range: NSMakeRange(0, selectablePart.length))
        // Add an underline to indicate this portion of text is selectable (optional)
        selectablePart.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: NSMakeRange(0,selectablePart.length))
        selectablePart.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor.black, range: NSMakeRange(0, selectablePart.length))
        // Add an NSLinkAttributeName with a value of an url or anything else
        selectablePart.addAttribute(NSAttributedString.Key.link, value: "signin", range: NSMakeRange(0,selectablePart.length))

        // Combine the non-selectable string with the selectable string
        text.append(selectablePart)

        // Center the text (optional)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        text.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, text.length))

        // To set the link text color (optional)
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        // Set the text view to contain the attributed text
        textView.attributedText = text
        // Disable editing, but enable selectable so that the link can be selected
        textView.isEditable = false
        textView.isSelectable = true
        // Set the delegate in order to use textView(_:shouldInteractWithURL:inRange)
        textView.delegate = self
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        // **Perform sign in action here**

        return false
    }
}
