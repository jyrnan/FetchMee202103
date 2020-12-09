//
//  AlertView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/17.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct AlertView: View {
    @EnvironmentObject var alerts: Alerts
    
    let offsetInScreen: CGFloat = 56 //偏移进入屏幕的数值
  
    @State private var offsetValue: CGFloat = -28 //初始的偏移值
    
    
    var body: some View {
        VStack(spacing: 0){
            if alerts.stripAlert.isPresentedAlert {
                HStack(spacing: 0){
                    Spacer()
                    Text(alerts.stripAlert.alertText)
                        .foregroundColor(.white)
                        .frame(height: 25, alignment: .center)
                        .onAppear {
                            withAnimation(){self.offsetValue = offsetInScreen}
                            delay(delay: 2) {
                                withAnimation{self.offsetValue = -28
                                }
                            }
                            delay(delay: 3) {
                                alerts.stripAlert.isPresentedAlert = false
                            }
                        }
                    
                    Spacer()
                }
                .frame(width: 150)
                
                .background(alerts.stripAlert.alertText.contains("Sorry") ? Color.red : Color.accentColor .opacity(0.8))
                .cornerRadius(12)
                .shadow(radius: 3 )
                .offset(y: self.offsetValue)
                Spacer()
            }
            Spacer()
        }.clipped() //通知条超出范围部分被裁减，产生形状缩减的效果
    }
    
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView().environmentObject(Alerts())
    }
}