//
//  AlertView.swift
//  FetchMeeBySwiftUI
//
//  Created by jyrnan on 2020/7/17.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

//@available (iOS, deprecated: 13.0)
struct AlertView: View {
    
    @EnvironmentObject var store: Store
    
    let offsetInScreen: CGFloat = 56 //偏移进入屏幕的数值
  
    @State private var offsetValue: CGFloat = -28 //初始的偏移值
    
    var isPresentedAlert: Bool {store.appState.setting.alert.isPresentedAlert}
    var alertText:String {store.appState.setting.alert.alertText}
    var isWarning: Bool {store.appState.setting.alert.isWarning}
    
    var body: some View {
        VStack(spacing: 0){
            if isPresentedAlert {
                HStack(spacing: 0){
                    Image(systemName: isWarning ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .foregroundColor(isWarning ? .red : .green)
                        .font(.title3)
                    Spacer()
                    
                    Text(alertText)
                        .font(.callout)
                        .frame(height: 25, alignment: .center)
                        .onAppear {
                            withAnimation(.interpolatingSpring(stiffness: 70, damping: 7)){self.offsetValue = offsetInScreen}
                            delay(delay: 2) {
                                withAnimation(.interpolatingSpring(stiffness: 70, damping: 7)){self.offsetValue = -28
                                }
                            }
                            delay(delay: 3) {
                                store.dispatch(.alertOff)
                            }
                        }
                    
                    Spacer()
                }
                .frame(width: 150)
                
                .background(Color.init("BackGroundLight"))
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
    static var store: Store = Store()
    static var previews: some View {
//        AlertView().environmentObject(store)
        Text("hello")
    }
}
