//
//  CALayer+Extension.swift
//  MobileProgect
//
//  Created by 于晓杰 on 2020/11/3.
//  Copyright © 2020 于晓杰. All rights reserved.
//

import UIKit

@IBDesignable extension CALayer {
    @IBInspectable var XIBBorderColor: UIColor {
        get {
            return UIColor(cgColor: borderColor!)
        }
        set {
            borderColor = newValue.cgColor
        }
    }
}
