//
//  PhotoPickerIconView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//
//应该没有用了。
import SwiftUI

//struct PhotoPickerIconView: View {
//    @Binding var imageData: ImageData
//    @State var isShowPhotoPicker: Bool = false
//    var body: some View {
//        Image(uiImage: self.imageData.image ?? UIImage(named: "defaultImage")!)
//            .resizable()
//            .aspectRatio(contentMode: .fill)
////            .frame(width: 64, height: 48, alignment: .center)
//            .onTapGesture {
//                if self.imageData.image == nil {
//                    self.isShowPhotoPicker = true
//                } else {
//                    self.imageData.image = nil
//                    self.imageData.data = nil
//                }
//
//            }
//            .sheet(isPresented: self.$isShowPhotoPicker) {
//                PhotoPicker(imageData: self.$imageData, isShowPhotoPicker: self.$isShowPhotoPicker)
//            }
//    }
//}
//
//struct PhotoPickerIconView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoPickerIconView(imageData: .constant(ImageData()))
//    }
//}
