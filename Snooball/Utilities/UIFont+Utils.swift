//
//  UIFont+Utils.swift
//  Snooball
//
//  Created by Justin Hill on 3/26/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import UIKit

extension UIFont {
    class func snb_preferredFont(forTextStyle style: UIFontTextStyle, weight: CGFloat) -> UIFont {
        let font = UIFont.preferredFont(forTextStyle: style)
        return UIFont.systemFont(ofSize: font.pointSize, weight: weight)
    }
}
