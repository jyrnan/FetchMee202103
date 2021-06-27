//
//  JSON+AttributeString.swift
//  FetchMee
//
//  Created by jyrnan on 2021/6/27.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter

extension JSON {
    func getAttributedString() -> AttributedString {
        let text = addReplyToAndWrap(status: self)
        
        var attString = AttributedString(text)
        
        setReplyingtoAttribute(status: self, attributedString: &attString)
        setHashTagAttribute(status: self, attributedString: &attString)
        setMentionAttribute(status: self, attributedString: &attString)
        setLinkAttribute(status: self, attributedString: &attString)
        return attString
    }
    
    func setReplyingtoAttribute(status: JSON, attributedString: inout AttributedString) {
        var attributeContainer = AttributeContainer()
        attributeContainer.foregroundColor = .secondary
        
        if let range = attributedString.range(of: "Replying to") {
            attributedString[range].mergeAttributes(attributeContainer)
        }
    }
    
    func setHashTagAttribute(status: JSON, attributedString: inout AttributedString) {
        guard let hashTags = status["entities"]["hashtags"].array, !hashTags.isEmpty else {return}
        
        var attributeContainer = AttributeContainer()
        attributeContainer.foregroundColor = .accentColor
        
        for hashTag in hashTags {
            if let range = attributedString.range(of: "#" + hashTag["text"].string!){
                attributedString[range].mergeAttributes(attributeContainer)
            }
        }
    }
    
    func setMentionAttribute(status: JSON, attributedString: inout AttributedString) {
        guard let user_mentions = status["entities"]["user_mentions"].array, !user_mentions.isEmpty else {return}
        
        var attributeContainer = AttributeContainer()
        attributeContainer.foregroundColor = .accentColor
        
        for user_mention in user_mentions {
            if let range = attributedString.range(of: "@" + user_mention["screen_name"].string!){
                attributedString[range].mergeAttributes(attributeContainer)
            }
        }
        
    }
    
    func setLinkAttribute(status: JSON, attributedString: inout AttributedString) {
        guard let urls = status["entities"]["urls"].array, !urls.isEmpty else {return}
        
        var attributeContainer = AttributeContainer()
        attributeContainer.foregroundColor = .blue
        
        for url in urls {
            if let range = attributedString.range(of: url["url"].string!){
                if let diplayUrl = url["dispaly_url"].string {
                var newAttributedString = AttributedString(diplayUrl)
                newAttributedString.link = URL(string: url["expanded_url"].string!)
                    attributedString.replaceSubrange(range, with: newAttributedString)
                    
                } else {
                attributedString[range].link = URL(string: url["expanded_url"].string!)
                }
            }
        }
    }
    
    func addReplyToAndWrap(status: JSON) -> String {
        guard let text = (self["text"].string ??  self["description"].string) else {return ""}
        guard text.first == "@" else {return text}
        
        var index = text.startIndex, indexNext = text.index(after: index)
        while indexNext < text.endIndex {
            if  text[index] == " ", text[indexNext] != "@" {
                return "Replying to " + text.replacingCharacters(in: (index...index), with: "\n")
            } else {
            index = indexNext
            indexNext = text.index(after: indexNext)
            }
        }
        return text
    }
    
}

//"url" : {
//  "urls" : [
//    {
//      "url" : "https://t.co/QNmXSU8QM1",
//      "indices" : [
//        0.0,
//        23.0
//      ],
//      "display_url" : "telegram.me/tsukomikun",
//      "expanded_url" : "http://telegram.me/tsukomikun"
//    }
//  ]
//},
//"description" : {
//  "urls" : [
//
//  ]
//}
//},
