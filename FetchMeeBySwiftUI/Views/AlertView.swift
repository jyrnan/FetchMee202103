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
    @State var offsetValue: CGFloat = -25
    var body: some View {
        
        
        HStack(spacing: 0){
                Spacer()
                Text(self.alertText)
                    .foregroundColor(.white)
                    .frame(height: 25, alignment: .center)
                    .onAppear {
                        withAnimation{self.offsetValue = 0}
                        delay(delay: 1) {
                            withAnimation{self.offsetValue = -25
                            }
                        }
                        delay(delay: 2) {
                            self.isAlertShow = false
                        }
                    }
                    
                Spacer()
            }.background(Color(UIColor.systemBlue).opacity(0.8))
        .offset(y: self.offsetValue)
        
           
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
