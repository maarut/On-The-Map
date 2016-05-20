//
//  UIColor+utils.swift
//  On The Map
//
//  Created by Maarut Chandegra on 18/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import Foundation
import UIKit

extension UIColor
{
    convenience init(hexValue: Int, alpha: CGFloat = 1.0)
    {
        let blue = CGFloat(hexValue % 0x100) / 256.0
        let green = CGFloat((hexValue / 0x100) % 0x100) / 256.0
        let red = CGFloat((hexValue / 0x10000)) / 256.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}