//
//  ImageThrumbViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/26.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import UIKit

class RemoteImageFetcher: ObservableObject {
    
    //MARK:-Properties
    @Published var image = UIImage(named: "defaultImage")!
    let imageUrl: String
    var imageType: ImageType
    
   //MARK:-Fucntions
    init(imageUrl: String, imageType: ImageType = .original) {
        self.imageUrl = imageUrl
        self.imageType = imageType
    }
    
    func getImage() {
        switch self.imageType {
        case .thumrb:
            let url = self.imageUrl + ":small"
            RemoteImageFetcher.imageDownloaderWithClosure(imageUrl: url, sh: dectectFaceAndSetImageValue(_:))
        case .original:
            let url = self.imageUrl
            RemoteImageFetcher.imageDownloaderWithClosure(imageUrl: url, sh: setImage(_:))
        } 
    }
     
    fileprivate func setImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.image = image ?? UIImage(named: "defaultImage")!
        }
    }
    
    /// 识别图片中的人像，如果有人像则按照人像优化裁剪
    /// 将识别后到image设定到被观察值
    /// - Parameter d: 图像文件的数据
    fileprivate func dectectFaceAndSetImageValue(_ image: UIImage) {
        
            image.detectFaces {result in
                let croppedImage = result?.cropByFace(image)
                _ = result?.drawnOn(image)
                self.setImage(croppedImage)
                
                if result?.count == 1 {
                    print(#line," Detected face!")
                }
            }
    }
    
    /// 获取图像的数据
    /// 先查找本地缓存是否有数据
    /// 如果没有则从网址下载
    /// 可以作为一个图片下载的标准程序来使用
    /// - Parameter imageUrl: 图片的URL位置
    static func imageDownloaderWithClosure(imageUrl: String, sh: @escaping (UIImage) -> Void) {
        let sh: (UIImage) -> Void = sh
        
        guard let url = URL(string: imageUrl) else { return}
        let fileName = url.lastPathComponent ///获取下载文件名用于本地存储
       
        let cachelUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let filePath = cachelUrl.appendingPathComponent(fileName, isDirectory: false)
        
        ///先尝试获取本地缓存文件
        if let data = try? Data(contentsOf: filePath), let image = UIImage(data: data) {
            sh(image)
            
        } else {
            let task = URLSession.shared.downloadTask(with: url) {
                fileURL, resp, err in
                if let url = fileURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    
                    ///先转存一份数据到本地
                    try? data.write(to: filePath)
                    
                    sh(image)
                }
            }
            task.resume()
        }
    }
}

extension RemoteImageFetcher {
    enum ImageType {
        case thumrb
        case original
    }
}
