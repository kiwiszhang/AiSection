//
//  AppIconHelper.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/8/9.
//

import UIKit

class AppIconHelper {    
    /// 获取当前 App 图标的名字（默认图标返回 "Default"）
    static func displayIconName() -> String {
        return UIApplication.shared.alternateIconName ?? "AppIcon"
    }
}
