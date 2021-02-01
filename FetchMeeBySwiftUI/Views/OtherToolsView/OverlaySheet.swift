//
//  OverlaySheet.swift
//  FetchMee
//
//  Created by jyrnan on 2021/1/30.
//  Copyright © 2021 jyrnan. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct OverlaySheet<Content: View>: View {
    
    private let isPresented: Binding<Bool>
    private let makeContent: () -> Content
    
    @GestureState private var translation = CGPoint.zero
    
    @State var keyboardHeight: CGFloat = 0
    
    init(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isPresented = isPresented
        self.makeContent = content
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            makeContent()
        }
        .offset(y: (isPresented.wrappedValue ? 0 : UIScreen.main.bounds.height) + max(0, translation.y) - keyboardHeight)
        .animation(.interpolatingSpring(stiffness: 70, damping: 12))
        .edgesIgnoringSafeArea(.bottom)
        .gesture(panelDraggingGesture)
        .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
    }
    
    var panelDraggingGesture: some Gesture {
        DragGesture()
            .updating($translation) {current, state, _ in
                state.y = current.translation.height
            }
            .onEnded {state in
                if state.translation.height > 150 {
                    self.isPresented.wrappedValue = false
                    self.hideKeyboard()
                }
            }
    }
}

extension View {
    func overlaySheet<Content: View> (
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View
    {
        overlay(
        OverlaySheet(isPresented: isPresented, content: content)
        )
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
