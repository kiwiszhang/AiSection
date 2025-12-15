//
//  UserDefaultsTools.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/8/8.
//

import UIKit
import KiwiPublicPod

class UserDefaultsTools {
    
    enum UserDefaultsTypeKeys:String {
        case isFirstInstallApp = "UserDefaultsTypeKeys_isFirstInstallApp"
        case tabSelected = "UserDefaultsTypeKeys_tabSelected"

        case reportOtherName = "UserDefaultsTypeKeys_reportOtherName"
        
        case selectedIdentifiers = "UserDefaultsTypeKeys_selectedIdentifiers"

    }
    
    /// 是否为第一次安装APP
    @UserDefault(UserDefaultsTypeKeys.isFirstInstallApp.rawValue, defaultValue: true)
    static var isFirstInstallApp: Bool
    
    /// 点击的Home顶部哪一个Tab
    @UserDefault(UserDefaultsTypeKeys.tabSelected.rawValue, defaultValue: 0)
    static var tabSelected: Int
    
    /// 报告页有的地方需要使用的别人名字
    @UserDefault(UserDefaultsTypeKeys.reportOtherName.rawValue, defaultValue: "")
    static var reportOtherName: String
    
    /// 照片选择标记
    @UserDefault(UserDefaultsTypeKeys.selectedIdentifiers.rawValue, defaultValue: [])
    static var selectedIdentifiers: [String]
   
    

    

}
