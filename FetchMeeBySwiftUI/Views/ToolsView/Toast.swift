//
//  ToastView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/10/28.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct Toast<Presenting>: View where Presenting: View {

    /// The binding that decides the appropriate drawing in the body.
    @Binding var isShowing: Bool
    /// The view that will be "presenting" this toast
    let presenting: () -> Presenting
    /// The text to show
    let image: UIImage

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .center) {

                self.presenting()
                    .blur(radius: self.isShowing ? 1 : 0)

                VStack(alignment: .center) {
                    
                    ImageViewer(image: image, presentedImageViewer: $isShowing)
                        
//                        .aspectRatio(contentMode: .fit)
                       
                  
                }
                .scaleEffect(isShowing ? 1 : 0)
                .frame(width: geometry.size.width,
                       height: geometry.size.height)
                
                .background(Color.black.opacity(0.8))
//                .foregroundColor(Color.primary)
//                .cornerRadius(20)
                .transition(.slide)
                .opacity(self.isShowing ? 1 : 0)
                .onTapGesture {
                    withAnimation{isShowing = false}
                    print(#line, #function)
                }

            }

        }.ignoresSafeArea()

    }

}

    extension View {

        func toast(isShowing: Binding<Bool>, image: UIImage) -> some View {
            Toast(isShowing: isShowing,
                  presenting: { self },
                  image: image)
        }

    }
