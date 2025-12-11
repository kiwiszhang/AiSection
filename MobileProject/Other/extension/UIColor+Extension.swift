//
//  UIColor+Extension.swift
//  MobileProgect
//
//  Created by csqiuzhi on 2019/4/30.
//  Copyright © 2019 于晓杰. All rights reserved.
//

import UIKit

extension UIColor {
    /// 随机色
    ///
    /// - Returns: 色值
    class func randomColor() -> UIColor {
        return UIColor.init(red: CGFloat(arc4random() % 256) / 255.0, green: CGFloat(arc4random() % 256) / 255.0, blue: CGFloat(arc4random() % 256) / 255.0, alpha: 1)
    }
    
    /// 线条色
    ///
    /// - Returns: 色值
    class func lineColor() -> UIColor {
        return UIColor.colorWithHexString("#F2F2F2")
    }
    
    /// 主题色
    ///
    /// - Returns: 色值
    class func theMeColor() -> UIColor {
        return UIColor.colorWithHexString("#FF771C")
    }
    
    /// 色值字符
    ///
    /// - Parameter colorStr: 色值字符串
    /// - Returns: 色值
    class func colorWithHexString(_ colorStr: String) -> UIColor {
        var hexString = colorStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 移除前缀（#、0X、0x）
        if hexString.hasPrefix("#") {
            hexString = String(hexString.dropFirst())
        } else if hexString.lowercased().hasPrefix("0x") {
            hexString = String(hexString.dropFirst(2))
        }
        
        // 验证长度（支持 3/6/8 位 HEX）
        guard [3, 6, 8].contains(hexString.count) else {
            return .clear
        }
        
        // 处理缩写形式（如 #RGB → #RRGGBB）
        if hexString.count == 3 {
            hexString = hexString.map { String($0) + String($0) }.joined()
        }
        
        // 解析 HEX 值
        let scanner = Scanner(string: hexString)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else {
            return .clear
        }
        
        // 分离颜色通道
        let r, g, b, a: CGFloat
        if hexString.count == 8 {
            // RRGGBBAA
            r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000FF) / 255
        } else {
            // RRGGBB（默认 Alpha=1）
            r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
            b = CGFloat(hexNumber & 0x0000FF) / 255
            a = 1.0
        }
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    ///  颜色转色值字符串
    func toHexString() -> String? {
        // 转换为 sRGB 颜色空间
        guard let sRGBColor = self.cgColor.converted(
            to: CGColorSpace(name: CGColorSpace.sRGB)!,
            intent: .defaultIntent,
            options: nil
        ) else { return nil }
        
        let color = UIColor(cgColor: sRGBColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard color.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        
        let rInt = Int(r * 255.0)
        let gInt = Int(g * 255.0)
        let bInt = Int(b * 255.0)
        
        return String(format: "#%02X%02X%02X", rInt, gInt, bInt)
    }
    
    /// 调整颜色亮度（返回新颜色）
    /// - Parameter brightness: 0.0（全黑）~ 1.0（最亮）
    func withBrightness(_ brightness: CGFloat) -> UIColor {
        // 1. 尝试获取 RGB 值（兼容所有颜色空间）
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard self.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            // 1.1 无法获取 RGB 时（如 pattern image 颜色），返回原色
            return self
        }
        
        // 2. 如果是纯黑或纯白，直接调整灰度值
        if r == g && g == b {
            return UIColor(white: r * brightness, alpha: a)
        }
        
        // 3. 转换为 HSB 并修改亮度
        var h: CGFloat = 0, s: CGFloat = 0, currentB: CGFloat = 0
        if self.getHue(&h, saturation: &s, brightness: &currentB, alpha: nil) {
            // 3.1 正常 HSB 颜色
            return UIColor(hue: h, saturation: s, brightness: brightness, alpha: a)
        } else {
            // 3.2 无法获取 HSB 时（理论上不会走到这里），回退到 RGB 混合
            let scale = brightness / max(r, g, b)
            return UIColor(red: r * scale, green: g * scale, blue: b * scale, alpha: a)
        }
    }
}
