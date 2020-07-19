//
//  AlertView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/17.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct AlertView: View {
    @Binding var isAlertShow: Bool
    var alertText: String = "This is a lert"
    var body: some View {
        
            HStack{
                Spacer()
                Text(self.alertText)
                    .foregroundColor(.white)
                    .frame(height: 35, alignment: .center)
                    .onAppear {
                        delay(delay: 1) {
                            withAnimation{
                                self.isAlertShow = false
                            }
                        }
                    }
                Spacer()
            }.background(Color(UIColor.systemBlue))
           
            Spacer()
        
    }
    
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView(isAlertShow: .constant(true))
    }
}
