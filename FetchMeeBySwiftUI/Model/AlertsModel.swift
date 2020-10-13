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
    @Published var stripAlert: MyAlert = MyAlert() //TimelineView的条形通知
//    @Published var stripAlertOfDetailView: MyAlert = MyAlert() //DetailView的条形通知
    @Published var standAlert: MyAlert = MyAlert()
    @Published var refreshIsDone: Bool = true
}
