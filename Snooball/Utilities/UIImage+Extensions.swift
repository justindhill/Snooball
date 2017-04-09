//
//  UIImage+Extensions.swift
//  Snooball
//
//  Created by Justin Hill on 4/9/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import UIKit

extension UIImage {
    class func transparentImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("ಠ_ಠ")
        }
        
        UIGraphicsEndImageContext()
        return image
    }
}
