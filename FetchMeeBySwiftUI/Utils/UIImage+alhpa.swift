//
//  UIImage+alhpa.swift
//  FetchMee
//
//  Created by jyrnan on 11/4/20.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import UIKit

extension UIImage {
    /**
     为UIImage增加一个透明的方法，可以直接在image后调用
     */
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

