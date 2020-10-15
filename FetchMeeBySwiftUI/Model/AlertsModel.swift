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
    @Published var logInfo: MyAlert = MyAlert()
}
