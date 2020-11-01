//
//  FaceDetect.swift
//  FetchMee
//
//  Created by jyrnan on 2020/9/26.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import UIKit
import Vision

extension UIImage {
    func detectFaces(completion: @escaping ([VNFaceObservation]?) -> ()) {
        guard let image = self.cgImage else {
            return completion(nil)
        }
        let request = VNDetectFaceRectanglesRequest()
        
        DispatchQueue.global().async {
            let handler = VNImageRequestHandler(cgImage: image,orientation: self.cgImageOrientation
                                                )
            
            try? handler.perform([request])
            
            guard let observations = request.results as? [VNFaceObservation] else {return completion(nil)}
            
            completion(observations)
            
        }
        
    }
}

extension UIImage {
    func fixOrientation() -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    var cgImageOrientation: CGImagePropertyOrientation {
        switch self.imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default:
            fatalError("Nothing")
        }
    }
}


extension Collection where Element == VNFaceObservation{
    func drawnOn(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)
        
        guard  let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(0.01 * image.size.width)
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -image.size.height)
        
        for observation in self {
            let rect = observation.boundingBox
            let normalizedRect = VNImageRectForNormalizedRect(rect, Int(image.size.width), Int(image.size.height)).applying(transform)
            
            context.stroke(normalizedRect)
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    /// 在识别头像的基础上，以以头像中心作为中心，将图片裁剪成最大的正方形
    /// - Parameter image: <#image description#>
    /// - Returns: <#description#>
    func cropByFace(_ image: UIImage) -> UIImage? {
        guard let observation = self.first else {return image}
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -image.size.height)
        
        let rect = observation.boundingBox
        let faceRect = VNImageRectForNormalizedRect(rect, Int(image.size.width), Int(image.size.height)).applying(transform)
        
        let newImageRectWidth = 2 * Swift.min(faceRect.center.x, image.size.width - faceRect.center.x)
        let newImageRectHeight = 2 * Swift.min(faceRect.center.y, image.size.height - faceRect.center.y)
        let newImageRectSize = CGSize(width: newImageRectWidth, height: newImageRectHeight)
        let newImageRect = CGRect(origin: CGPoint(x: faceRect.center.x - newImageRectWidth / 2.0, y: faceRect.center.y - newImageRectHeight / 2.0),
                                  size: newImageRectSize)
        
        //设定判断如果人像范围太小，则不裁剪图片
        guard newImageRectWidth / image.size.width > 0.3 || newImageRectHeight / image.size.height > 0.5 else {
            return image
        }
        
        UIGraphicsBeginImageContext(newImageRectSize)
        
        guard  let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let willDrawRect = CGRect(origin: CGPoint(x: 0  - newImageRect.origin.x, y: 0 - newImageRect.origin.y),
                                  size: image.size)
        image.draw(in: willDrawRect)
        
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(0.01 * image.size.width)
                
        
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
//        print(#line, "croped by face...")
        return croppedImage
    }
}
