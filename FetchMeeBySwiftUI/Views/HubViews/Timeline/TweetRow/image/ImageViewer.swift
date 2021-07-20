//
//  ImageViewer.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ImageViewer: View {
    @Environment(\.dismiss) var dismiss
    var image: UIImage
    
    @State var currentScale: CGFloat = 1.0
    @State var previousScale: CGFloat = 1.0
    
    @State var currentOffset = CGSize.zero
    @State var previousOffset = CGSize.zero
    
    @State var pointTapped: CGPoint = CGPoint.zero
    
    @State var isShowSharesheet : Bool = false
    
    private var imageView: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .offset(x: self.currentOffset.width, y: self.currentOffset.height)
            .scaleEffect(max(self.currentScale, 1.0), anchor: .center)
            
            .gesture(TapGesture(count: 2)
                        .onEnded{
                if self.currentScale == 3 {
                    withAnimation{
                        self.currentScale = 1
                        currentOffset = CGSize.zero
                    }
                } else {
                    withAnimation{self.currentScale = 3}
                }
            })
        
            .gesture(TapGesture(count: 1)
                        .onEnded{
                guard currentScale == 1.0 else {return}
                dismiss()
            })
        
            .gesture(LongPressGesture()
                        .onEnded{_ in
                self.isShowSharesheet = true
            })
            .gesture(DragGesture()
                        .onChanged { value in
                self.pointTapped = value.startLocation
                
                let deltaX = value.translation.width - self.previousOffset.width
                let deltaY = value.translation.height - self.previousOffset.height
                self.previousOffset.width = value.translation.width
                self.previousOffset.height = value.translation.height
                
                self.currentOffset.width = self.currentOffset.width + deltaX / self.currentScale
                self.currentOffset.height = self.currentOffset.height + deltaY / self.currentScale }
                        .onEnded { value in self.previousOffset = CGSize.zero })
        
            .gesture(MagnificationGesture()
                        .onChanged { value in
                let delta = value / self.previousScale
                self.previousScale = value
                self.currentScale = self.currentScale * delta
            }
                        .onEnded { value in self.previousScale = 1.0 }
            )
    }
    
    private var closeButton: some View {
        VStack {
            Spacer()
            Button(action: {dismiss()},
                   label: {
                Text("Close").opacity(currentScale == 1 ? 1.0 : 0)
            })
                .tint(.accentColor)
        }
    }
    
    var body: some View {
        ZStack {
            imageView
            closeButton
        }
        .sheet(isPresented: self.$isShowSharesheet, content: {
            ShareSheet(activityItems: [self.image])
        })
    }
}

struct ImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewer(image: UIImage(named: "defaultImage")!)
    }
}
