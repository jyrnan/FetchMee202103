//
//  ReplyUserViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/3.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import UIKit
import Swifter

class ReplyUserViewModel: ObservableObject {
    var status: JSON
    
    var replyUsers: [String]? {getUserMentions(status: status)}
    
    var attributedString: MyCustomTextModel!
    
    init(status: JSON) {
        self.status = status
        let attString = setAttributeString(status: status)
        
        attributedString = MyCustomTextModel(myCustomAttributedString: attString)
       
    }
    
    func getReplyUsers(status: JSON) -> [String] {
        let text = status["text"].string
        let replyUsers = convertTweetText(from: text).0
        return replyUsers
    }
    
    /**
     把回复用户名从推文中分离出来
     */
    func convertTweetText(from originalTweetText: String?) -> ([String], [String]) {
        var replyUsers: [String] = []
        var tweetText: [String] = []
        guard originalTweetText != nil else{return (replyUsers, tweetText)}
        tweetText = originalTweetText!.split(separator: " ").map{String($0)}
        
        for string in tweetText {
            if string.first != "@" {
                break
            }
            replyUsers.append(string)
        }
        if !replyUsers.isEmpty {
            tweetText.removeFirst(replyUsers.count)
        }
        return (replyUsers, tweetText)
    }
    
    func getUserMentions(status: JSON) -> [String]? {
        guard let userMentions = status["entities"]["user_mentions"].array,
              !userMentions.isEmpty else {return nil}
        let replyUsers:[String] = userMentions.map{$0["screen_name"].string!}
        return replyUsers
    }
    
    func setAttributeString(status: JSON) -> NSMutableAttributedString {
        guard let user_mentions = status["entities"]["user_mentions"].array, !user_mentions.isEmpty else {return NSMutableAttributedString(string: "")}
        
        let text = status["text"].string ?? ""
        let attributedString = NSMutableAttributedString(string: text)
        
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


struct MyCustomTextModel {
    var myCustomAttributedString: NSMutableAttributedString = {
        let myTestString = "Attributed string"
        let attributedString = NSMutableAttributedString(string: myTestString)
        
        let attributes1 = [NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 25)!, .foregroundColor: UIColor.orange, NSAttributedString.Key.kern: 10] as [NSAttributedString.Key : Any]
        
        attributedString.addAttributes(attributes1, range: NSRange(location: 0, length: "Attributed ".count))
        
        let attributes2 = [NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 25)!, .foregroundColor: UIColor.black]

        attributedString.addAttributes(attributes2, range: NSRange(location: "Attributed".count + 1, length: "string".count))

        return attributedString
    }()
}
