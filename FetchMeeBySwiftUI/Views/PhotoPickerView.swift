//
//  PhotoPickerView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import UIKit
import Photos
import PhotosUI

//封装的数据格式，返回两个值
struct ImageData {
    var image: UIImage?
    var data: Data?
}

struct PhotoPicker: UIViewControllerRepresentable {
    
    @Binding var imageData: ImageData
    @Binding var isShowPhotoPicker: Bool

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(imageData: self.$imageData, isShowPhotoPicker: self.$isShowPhotoPicker)
        return coordinator
    }
    
   
    typealias UIViewControllerType = UIImagePickerController
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let src = UIImagePickerController.SourceType.photoLibrary
        guard UIImagePickerController.isSourceTypeAvailable(src) else  {return UIImagePickerController()}
        guard let arr = UIImagePickerController.availableMediaTypes(for: src) else {return UIImagePickerController()}
        let picker = UIImagePickerController()
        picker.sourceType = src
        picker.mediaTypes = arr
        picker.delegate = context.coordinator
        picker.videoExportPreset = AVAssetExportPreset640x480
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        print(#line)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var imageData: Binding<ImageData>
        var isShowPhotoPicker: Binding<Bool>
        init(imageData: Binding<ImageData>, isShowPhotoPicker: Binding
        <Bool>) {
            self.imageData = imageData
            self.isShowPhotoPicker = isShowPhotoPicker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            var imageData = ImageData()
            
            let _ = info[.phAsset] as? PHAsset
            let _ = info[.imageURL] as? URL
            let im = info[.originalImage] as? UIImage
            if let imurl = info[.imageURL] as? URL {
                if let data = try? Data(contentsOf: imurl) {
                    imageData.data = data
                }
            }
            self.imageData.image.wrappedValue = im
            print(#line, self.imageData)
            self.isShowPhotoPicker.wrappedValue = false
        }
    }
}
