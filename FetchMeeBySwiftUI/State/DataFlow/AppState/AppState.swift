//
//  AppState.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/23.
//  Copyright © 2021 jyrnan. All rights reserved.
//


import Combine
import Swifter
import SwiftUI

struct AppState {
    var setting = Setting()
    var timelineData = TimelineData()
}

extension AppState {
    
    struct Setting {
        
        struct Alert {
            var isPresentedAlert: Bool = false
            var alertText: String = ""
            var isWarning: Bool = false
        }
        
        ///产生一个Publisher，用来检测输入文字是否含有#或@
        class TweetTextChecker {
            @Published var tweetText = ""
            var autoMapPublisher: AnyPublisher<String, Never> {
                $tweetText
                    .debounce(
                        for: .milliseconds(500),
                        scheduler: DispatchQueue.global()
                    )
                    .receive(on: DispatchQueue.global())
                    .compactMap{text in
                        guard text != "" else {return "noTag"}
                        guard text.last != " " else {return "noTag"}
                        guard text.last != "\n" else {return "noTag"}
                        if let output = text.split(whereSeparator: {$0 == " " || $0 == "\n"}).last,
                                                          (output.starts(with: "@") || output.starts(with: "#"))
                        { return String(output)}
                        return "noTag"
                                            }
                    .removeDuplicates()
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
        }
        
        struct TweetTag: Equatable,Hashable,Codable {
            var priority: Int = 0
            let text: String
        }
       
        var alert = Alert()
        
        var isProcessingDone: Bool = true
        
        var isShowImageViewer: Bool = false //是否浮动显示图片
        var presentedView: AnyView? //通过AnyView就可以实现任意View的传递了？！
        
        ///User及login部分
        @FileStorage(directory: .documentDirectory, fileName: "user.json")
        var loginUser: User?
        
        @FileStorage(directory: .documentDirectory, fileName: "userSetting.json")
        var userSetting: UserSetting?
        
        var loginRequesting = false
        var loginError: AppError?
        
        var lists: [String: String] = [:] //前面是ID，后面是name
        
        var tweetInput = TweetTextChecker()
        var autoCompleteText: String = "noTag"
        
        
    }
}



    
