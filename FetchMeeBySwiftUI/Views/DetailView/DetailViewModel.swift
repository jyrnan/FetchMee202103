//
//  DetailViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/5.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import Swifter

class DetailViewModel: TimelineViewModel, ObservableObject {
    @Published var tweetIDStrings: [String] = []
    @Published var isDone: Bool = false
    @Published var tweetIDStringOfRowToolsViewShowed: String? = nil
    var newTweetNumber: Int = 0
    
    var tweetIDString: String //传入DetailView的初始推文
    
    
    
    init(tweetIDString: String) {
        self.tweetIDString = tweetIDString
//        tweetIDStringOfRowToolsViewShowed = tweetIDString
        
        getReplyDetail(for: tweetIDString)
    }
    
    
    func getReplyDetail(for idString: String ) {
        self.isDone = false
        let failureHandler: (Error) -> Void = { error in
            print(#line, error.localizedDescription)}
        
        var counter: Int = 0
        
        func finalReloadView() {
            //最后操作，可能需要
            self.isDone = true
          
        }
        func sh(json: JSON) -> () {
            let status:JSON = json
            guard let newTweetIDString = status["id_str"].string else {return}
            
            ///MVVM
            StatusRepository.shared.addStatus(status)
            ///MVVM END
            
        
            self.tweetIDStrings = [newTweetIDString] + self.tweetIDStrings
            if let in_reply_to_status_id_str = status["in_reply_to_status_id_str"].string, counter < 8 {
                swifter.getTweet(for: in_reply_to_status_id_str, success: sh, failure: failureHandler)
                counter += 1
            } else {
                finalReloadView()
            }
        }
        swifter.getTweet(for: idString, success: sh, failure: failureHandler)
    }
}
