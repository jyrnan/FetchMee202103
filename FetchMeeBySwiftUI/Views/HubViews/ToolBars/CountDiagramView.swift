//
//  CountDiagramView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/16.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData

struct CountDiagramView: View {
    @EnvironmentObject var loginUser: User
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    
    @State var countValue: CountValue
    
    init() {
        _countValue.wrappedValue = Count.updateCount(for: loginUser.info, in: viewContext)
    }
   
    var body: some View {
        Text("hello")
    }
}
