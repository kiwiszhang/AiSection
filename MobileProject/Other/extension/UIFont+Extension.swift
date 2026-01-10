//
//  UIFont+Extension.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/4/17.
//

import Foundation

//enum HelveticaNeueWeight: String {
//    case ultraLight = "UltraLight"
//    case light = "Light"
//    case regular = ""          // HelveticaNeue 无后缀
//    case medium = "Medium"
//    case bold = "Bold"
//    case condensedBold = "CondensedBold"
//}

public enum InterWeightOner {
    case light, regular, medium, bold
}

public enum ArchivoBlackWeightOner {
    case  regular
}



public extension UIFont {
    static func interOner(size: CGFloat, weight: InterWeightOner = .regular) -> UIFont {
        
//        let fontName = "HelveticaNeue" + (weight.rawValue.isEmpty ? "" : "-\(weight.rawValue)")
//        if let font = UIFont(name: fontName, size: size) {
//            return font
//        }
        
        // 对应 SwiftGen fonts.yml 里生成的
        let fontConvertible: FontConvertible
        switch weight {
        case .light:
            fontConvertible = FontFamily.Inter.lightBETA
        case .regular:
            fontConvertible = FontFamily.Inter.regular
        case .medium:
            fontConvertible = FontFamily.Inter.medium
        case .bold:
            fontConvertible = FontFamily.Inter.bold
        }
        
        let customFont = fontConvertible.font(size: size)
        return customFont


    }
    
//    static func archivoBlackOner(size: CGFloat, weight: ArchivoBlackWeightOner = .regular) -> UIFont {
//        // 对应 SwiftGen fonts.yml 里生成的
//        let fontConvertible: FontConvertible
//        switch weight {
//            case .regular:
////            fontConvertible = FontFamily.ArchivoBlack.regular
//        }
//        let customFont = fontConvertible.font(size: size)
//        return customFont
//    }

}

public extension UILabel {
    //每个项目单独处理
    @discardableResult
    func hnFont(size: CGFloat, weight: InterWeightOner) -> Self {
        self.font = UIFont.interOner(size: size, weight: weight)
        return self
    }
    
//    @discardableResult
//    func abFont(size: CGFloat, weight: ArchivoBlackWeightOner = .regular) -> Self {
//        self.font = UIFont.archivoBlackOner(size: size, weight: weight)
//        return self
//    }

}

public extension UITextField {
    @discardableResult
    func hnFont(size: CGFloat, weight: InterWeightOner = .regular) -> Self {
        self.font = UIFont.interOner(size: size, weight: weight)
        return self
    }
}

public extension UITextView {
    @discardableResult
    func hnFont(size: CGFloat, weight: InterWeightOner = .regular) -> Self {
        self.font = UIFont.interOner(size: size, weight: weight)
        return self
    }
}
