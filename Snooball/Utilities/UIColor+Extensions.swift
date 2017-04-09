//
//  UIColor+Extensions.swift
//  Snooball
//
//  Created by Justin Hill on 4/9/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import UIKit

extension UIColor {
    func darkened(byPercent percent: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        func darken(_ component: CGFloat, _ percent: CGFloat) -> CGFloat {
            return component - ((percent * 100) / 255)
        }
        
        return UIColor(red: darken(red, percent), green: darken(green, percent), blue: darken(blue, percent), alpha: alpha)
    }
}
