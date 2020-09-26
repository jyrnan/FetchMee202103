//
//  SaliencyDetection.swift
//  FetchMee
//
//  Created by jyrnan on 2020/9/26.
//  Copyright © 2020 jyrnan. All rights reserved.
//
//  参考了人工智能一书，本文件主要是为了实现重点区域识别并裁剪的功能。但目前测试效果不甚理想

import UIKit
import Vision

public extension CGSize {
    func scaledFactor(to size: CGSize) -> CGFloat {
        let horizontalScale = self.width / size.width
        let verticalScale = self.height / size.height
        return max(horizontalScale, verticalScale)
    }
}

public extension CGRect {
    func scaled(by scaleFactor: CGFloat) -> CGRect {
        let horizontalInsets = (self.width - (self.width * scaleFactor)) / 2.0
        let verticalInsets = (self.height - (self.height * scaleFactor)) / 2.0
        
        let edgeInsets = UIEdgeInsets(top: verticalInsets,
                                      left: horizontalInsets,
                                      bottom: verticalInsets,
                                      right: horizontalInsets)
        
        let leftOffset = min(self.origin.x + horizontalInsets, 0)
        let upOffset = min(self.origin.y + verticalInsets, 0)
        
        return self
            .inset(by: edgeInsets)
            .offsetBy(dx: -leftOffset, dy: -upOffset)
    }
    
    func cropped(to size: CGSize, centering: Bool = true) -> CGRect {
        if centering {
            let horizontalDifference = self.width - size.width
            let verticalDifference = self.height - size.height
            let newOrigin = CGPoint(
                x: self.origin.x + (horizontalDifference / 2.0),
                y: self.origin.y + (verticalDifference / 2.0)
            )
            return CGRect(
                x: newOrigin.x,
                y: newOrigin.y,
                width: size.width,
                height: size.height
            )
        }
        
        return CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
}

public extension UIImage {
    var width: CGFloat {
        return self.size.width
    }
    
    var height: CGFloat {
        return self.size.height
    }
    
    var rect: CGRect {
        return CGRect(x: 0, y: 0, width: self.width, height: self.height)
    }
    
    var invertTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.height)
    }
    
    func cropped(to size: CGSize, centering: Bool = true) -> UIImage? {
        let newRect = self.rect.cropped(to: size, centering: centering)
        return self.cropped(to: newRect, centering: centering)
    }
    
    func cropped(to rect: CGRect, centering: Bool = true) -> UIImage? {
        let newRect = rect.applying(self.invertTransform)
        UIGraphicsBeginImageContextWithOptions(newRect.size, false, 0)
        
        guard let cgImage = self.cgImage, let context = UIGraphicsGetCurrentContext() else {return nil}
        
        context.translateBy(x: 0.0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.draw(cgImage, in: CGRect(x: -newRect.origin.x, y: newRect.origin.y, width: self.width, height: self.height), byTiling: false)
        
        context.clip(to: [newRect])
        
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return croppedImage
    }
    
    func scaled(by scaleFactor: CGFloat) -> UIImage? {
        if scaleFactor.isZero { return self }

        let newRect = self.rect
            .scaled(by: scaleFactor)
            .applying(self.invertTransform)

        UIGraphicsBeginImageContextWithOptions(newRect.size, false, 0)

        guard let cgImage = self.cgImage,
            let context = UIGraphicsGetCurrentContext() else { return nil }

        context.translateBy(x: 0.0, y: newRect.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(
            cgImage,
            in: CGRect(
                x: 0,
                y: 0,
                width: newRect.width,
                height: newRect.height),
            byTiling: false)

        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
}

            

extension VNImageRequestHandler {
    convenience init?(uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage else {return nil}
        let orientation = uiImage.cgImageOrientation
        
        self.init(cgImage: cgImage, orientation: orientation)
    }
}

extension VNRequest {
    func queueFor(image: UIImage,  completion: @escaping ([Any]?) -> ()) {
        DispatchQueue.global().async {
            if let handler = VNImageRequestHandler(uiImage: image) {
                try? handler.perform([self])
                completion(self.results)
            } else {
                return completion(nil)
            }
        }
    }
}

extension UIImage {
    
    enum  SaliencyType {
        case objectnessBased, attentionBased
        
        var request: VNRequest {
            switch self {
            case .objectnessBased:
                return VNGenerateObjectnessBasedSaliencyImageRequest()
            case .attentionBased:
                return VNGenerateAttentionBasedSaliencyImageRequest()
            }
        }
    }
    
    func detectSalientRegions(prioritising saliencyType: SaliencyType = .attentionBased,
                              completion: @escaping (VNSaliencyImageObservation?) -> ()) {
        
        let request = saliencyType.request
        
        request.queueFor(image: self) {
            result in
            completion(result?.first as? VNSaliencyImageObservation)
        }
    }
    
    func cropped(
        with saliencyObservation: VNSaliencyImageObservation?,
        to size: CGSize? = nil) -> UIImage? {
        
        guard let saliencyMap = saliencyObservation,
              let salientObjects = saliencyMap.salientObjects else {
            return nil
        }
        
        let salientRect = salientObjects.reduce(into: CGRect.zero) {
            rect, object in
            rect = rect.union(object.boundingBox)
        }
        let nomalizedSalientRect = VNImageRectForNormalizedRect(salientRect, Int(self.size.width), Int(self.size.height))
        
        var finalImage: UIImage?
        
        if let desiredSize = size {
            if self.size.width < desiredSize.width ||
                self.size.height < desiredSize.height {return nil}
            
            let scaleFactor = desiredSize.scaledFactor(to: nomalizedSalientRect.size)
            
            finalImage = self.cropped(to: nomalizedSalientRect)
            
            finalImage = finalImage?.scaled(by: -scaleFactor)
            
            finalImage = finalImage?.cropped(to: desiredSize)
        } else {
            finalImage = finalImage?.cropped(to: nomalizedSalientRect)
        }
        return finalImage
    }
}
