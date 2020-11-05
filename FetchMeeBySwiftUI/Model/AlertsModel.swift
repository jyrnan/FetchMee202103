//
//  AlertModel.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/17.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct MyAlert: Identifiable {
    var id = UUID()
    var isPresentedAlert: Bool = false
    var alertText: String = ""
        }

class Alerts: ObservableObject {
    @Published var stripAlert: MyAlert = MyAlert()
    @Published var standAlert: MyAlert = MyAlert()
    @Published var refreshIsDone: Bool = true
    
    //可以在hubView的toolbar里面显示一行信息，并作为log输出信息
    @Published var logMessage: MyAlert = MyAlert()
    
    @Published var isShowingPicture: Bool = false //是否浮动显示图片
    @Published var presentedView: AnyView? //通过AnyView就可以实现任意View的传递了？！
    
    func setLogInfo(text: String) {
        DispatchQueue.main.async {
            self.logMessage.alertText = text
        }
    }
}
