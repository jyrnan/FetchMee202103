//
//  ToastView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/28.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct Toast<Presenting, Presented>: View where Presenting: View, Presented: View {
    
    @EnvironmentObject var fetchMee: AppData
    
    /// The binding that decides the appropriate drawing in the body.
    @Binding var isShowing: Bool
    /// The view that will be "presenting" this toast
    let presenting: () -> Presenting
    /// 被显示的View
    let presented: Presented?
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .center) {
                
                self.presenting()
                    .blur(radius: self.isShowing ? 5 : 0)
                
                VStack(alignment: .center) {
                    self.presented    
                }
                .scaleEffect(isShowing ? 1 : 0)
                .frame(width: geometry.size.width,
                       height: geometry.size.height)
                
                .background(Color.black.opacity(0.8))
                //                .transition(.slide)
                .opacity(self.isShowing ? 1 : 0)
                .onTapGesture {
                    withAnimation(Animation.linear){
                        isShowing = false
                    }
                    
                    //通过设置延时后设置需要显示的View为nil，可以保证下次显示的时候是初始设置。（为什么会这样还有点迷惑）
                    //延时的目的是保证缩放的动画完成
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {fetchMee.presentedView = nil})
                    
                }
            }
            
        }.ignoresSafeArea()
    }
}

extension View {
    
    func toast<T : View>(isShowing: Binding<Bool>, presented: T?) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              presented: presented)
    }
    
}

extension View {
    
    @ViewBuilder
    func ifThis<Transform: View> (_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        }
        else {
            self
        }
    }
}
