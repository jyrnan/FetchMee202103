//
//  ToastView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/28.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct Toast<Presenting, Presented>: View where Presenting: View, Presented: View {

    /// The binding that decides the appropriate drawing in the body.
    @Binding var isShowing: Bool
    /// The view that will be "presenting" this toast
    let presenting: () -> Presenting
    /// The text to show
    let presented: Presented

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .center) {

                self.presenting()
                    .blur(radius: self.isShowing ? 5 : 0)

                VStack(alignment: .center) {
                    
                    self.presented
               
                }
//                .scaleEffect(isShowing ? 1 : 0)
                .frame(width: geometry.size.width,
                       height: geometry.size.height)
                
                .background(Color.black.opacity(0.8))
//                .transition(.slide)
                .opacity(self.isShowing ? 1 : 0)
                .onTapGesture {
                    
                    if let imageViewer = self.presented as? ImageViewer {
                        imageViewer.currentOffset = CGSize.zero
                        
                    }
                    withAnimation{isShowing = false}
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
