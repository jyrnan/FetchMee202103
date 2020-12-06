//
//  User.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/15.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter
import Combine
import CoreData


class User: ObservableObject {
   
    @Published var isLoggedIn: Bool = false
    @Published var info: UserInfo //用户的基本信息
    @Published var lists: [String: ListTag] = [:]
    
    

    @Published var setting: UserSetting = UserSetting() //打算把setting放这里,现在是在SeceneDelegate里面读取
    
    var viewContext: NSManagedObjectContext {
        get {
        var context: NSManagedObjectContext!
        if let windowsScenen = UIApplication.shared.connectedScenes.first as? UIWindowScene ,
               let sceneDelegate = windowsScenen.delegate as? SceneDelegate
         {
         context = sceneDelegate.context
         }
            return context }
    }
    
    
    init(userIDString: String = "0000", screenName: String? = nil) {
        self.info = UserInfo(id: userIDString, screenName: screenName)
    }
}

