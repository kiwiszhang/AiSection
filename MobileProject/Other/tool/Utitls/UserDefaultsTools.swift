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

        case segmentIndex = "UserDefaultsTypeKeys_segmentIndex"
        
        case langSelected = "UserDefaultsTypeKeys_langSelected"
        case transcritionSelected = "UserDefaultsTypeKeys_transcritionSelected"
        case recordLangugasSelected = "UserDefaultsTypeKeys_recordLangugasSelected"

    }
    
    /// 是否为第一次安装APP
    @UserDefault(UserDefaultsTypeKeys.isFirstInstallApp.rawValue, defaultValue: true)
    static var isFirstInstallApp: Bool
    
    /// 点击的Home顶部哪一个Tab
    @UserDefault(UserDefaultsTypeKeys.tabSelected.rawValue, defaultValue: 0)
    static var tabSelected: Int
    
    /// segment选中的Index
    @UserDefault(UserDefaultsTypeKeys.segmentIndex.rawValue, defaultValue: 0)
    static var segmentIndex: Int
    
    /// 设置页设置语言
    @UserDefault(UserDefaultsTypeKeys.langSelected.rawValue, defaultValue: "")
    static var langSelected: String
    /// 设置页设置总结转写语言
    @UserDefault(UserDefaultsTypeKeys.transcritionSelected.rawValue, defaultValue: "en")
    static var transcritionSelected: String
    
    /// 语音识别语言设置
    @UserDefault(UserDefaultsTypeKeys.recordLangugasSelected.rawValue, defaultValue: "en_US")
    static var recordLangugasSelected: String
   
    

    

}
