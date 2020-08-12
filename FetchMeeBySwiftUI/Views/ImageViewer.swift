//
//  ImageViewer.swift
//  FetchMeeBySwiftUI
//
//  Created by yoeking on 2020/7/12.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ImageViewer: View {
    @Environment(\.presentationMode) var presentationMode
    var image: UIImage
    @Binding var presentedImageViewer: Bool
    
    @State var currentScale: CGFloat = 1.0
    @State var previousScale: CGFloat = 1.0

    @State var currentOffset = CGSize.zero
    @State var previousOffset = CGSize.zero
    
    @State var pointTapped: CGPoint = CGPoint.zero

    var body: some View {

        ZStack {
            VStack {
                Spacer()
                GeometryReader { geometry in // here you'll have size and frame
                    Image(uiImage: image)
                        .resizable()
    //                    .edgesIgnoringSafeArea(.all)
                        .scaledToFit()
//                        .animation(.default)
                        .offset(x: self.currentOffset.width, y: self.currentOffset.height)
                        .scaleEffect(max(self.currentScale, 1.0))
//                        .scaleEffect(max(self.currentScale, 1.0), anchor: UnitPoint(x: self.pointTapped.x / geometry.frame(in: .global).maxX, y: self.pointTapped.y / geometry.frame(in: .global).maxY)) // the second question
                        .gesture(TapGesture(count: 2)
                                    .onEnded{
                                        if self.currentScale == 3 {
                                            withAnimation{self.currentScale = 1}
                                        } else {
                                            withAnimation{self.currentScale = 3}
                                        }
                                    })
                        
                        .gesture(DragGesture()
                            .onChanged { value in
//                                self.pointTapped = value.startLocation

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
                        .onEnded { value in self.previousScale = 1.0 })
                }
                Spacer()
            }

            

            VStack {

                Spacer()
                Text("Close")
                    .padding(4)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .clipShape(Capsule())
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }

//                Button(action: {self.presentedImageViewer.toggle()}, label: {
//                    Text("Close")
//                })
            }
        }
    }
}

struct ImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewer(image: UIImage(named: "defaultImage")!, presentedImageViewer: .constant(true))
    }
}
