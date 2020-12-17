//
//  UIImage+changeColor.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/17.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import UIKit

extension UIImage {
      func changeWithColor(color: UIColor) -> UIImage? {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

