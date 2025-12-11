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
        case isSingleReceipt = "UserDefaultsTypeKeys_isSingleReceipt"
        case isFromSearchMerchant = "UserDefaultsTypeKeys_isFromSearchMerchant"

        case reportOtherName = "UserDefaultsTypeKeys_reportOtherName"
        
        case butSelected = "UserDefaultsTypeKeys_butSelected"
        case selectedIdentifiers = "UserDefaultsTypeKeys_selectedIdentifiers"

        case currencyCountry = "UserDefaultsTypeKeys_currencyCountry"
        case currencyFlag = "UserDefaultsTypeKeys_currencyFlag"
        case currencyName = "UserDefaultsTypeKeys_currencyName"
        case currencySymbol = "UserDefaultsTypeKeys_currencySymbol"
        
        case demoReceiptSelected = "UserDefaultsTypeKeys_demoReceiptSelected"

        case userDefaultsMerchantName = "UserDefaultsTypeKeys_userDefaultsMerchantName"
        case userDefaultsTatolMoney = "UserDefaultsTypeKeys_userDefaultsTatolMoney"
        case userDefaultsTaxMoney = "UserDefaultsTypeKeys_userDefaultsTaxMoney"
        case userDefaultsCurrencyText = "UserDefaultsTypeKeys_userDefaultsCurrencyText"
        case userDefaultsDateText = "UserDefaultsTypeKeys_userDefaultsDateText"
        case userDefaultsCategoryText = "UserDefaultsTypeKeys_userDefaultsCategoryText"
        case userDefaultsNoteText = "UserDefaultsTypeKeys_userDefaultsNoteText"

    }
    
    /// 是否为第一次安装APP
    @UserDefault(UserDefaultsTypeKeys.isFirstInstallApp.rawValue, defaultValue: true)
    static var isFirstInstallApp: Bool
    
    /// 是点击单张还是多张
    @UserDefault(UserDefaultsTypeKeys.isSingleReceipt.rawValue, defaultValue: 0)
    static var isSingleReceipt: Int
    /// 是否是从报告空白页过去的
    @UserDefault(UserDefaultsTypeKeys.isFromSearchMerchant.rawValue, defaultValue: false)
    static var isFromSearchMerchant: Bool
    
    /// 报告页有的地方需要使用的别人名字
    @UserDefault(UserDefaultsTypeKeys.reportOtherName.rawValue, defaultValue: "")
    static var reportOtherName: String
    
    /// 总结模块上面三个按钮的选择情况
    @UserDefault(UserDefaultsTypeKeys.butSelected.rawValue, defaultValue: 1)
    static var butSelected: Int
    
    /// 照片选择标记
    @UserDefault(UserDefaultsTypeKeys.selectedIdentifiers.rawValue, defaultValue: [])
    static var selectedIdentifiers: [String]
    
    // MARK: -  =====================选择国家货币符号用的字段=========================
    @UserDefault(UserDefaultsTypeKeys.currencyCountry.rawValue, defaultValue: "United States")
    static var currencyCountry: String
    
    @UserDefault(UserDefaultsTypeKeys.currencyFlag.rawValue, defaultValue: "🇺🇸")
    static var currencyFlag: String
    
    @UserDefault(UserDefaultsTypeKeys.currencyName.rawValue, defaultValue: "United States Dollar")
    static var currencyName: String
    
    @UserDefault(UserDefaultsTypeKeys.currencySymbol.rawValue, defaultValue: "$")
    static var currencySymbol: String
    
    /// 点击的demo哪一张图片
    @UserDefault(UserDefaultsTypeKeys.demoReceiptSelected.rawValue, defaultValue: 0)
    static var demoReceiptSelected: Int

    
    // MARK: -  =====================添加消费地方用的字段=========================
    /// 商家名
    @UserDefault(UserDefaultsTypeKeys.userDefaultsMerchantName.rawValue, defaultValue: "")
    static var userDefaultsMerchantName: String
    /// 总消费
    @UserDefault(UserDefaultsTypeKeys.userDefaultsTatolMoney.rawValue, defaultValue: 0.0)
    static var userDefaultsTatolMoney: Double
    /// 税金
    @UserDefault(UserDefaultsTypeKeys.userDefaultsTaxMoney.rawValue, defaultValue: 0.0)
    static var userDefaultsTaxMoney: Double
    /// 钱币类型
    @UserDefault(UserDefaultsTypeKeys.userDefaultsCurrencyText.rawValue, defaultValue: "")
    static var userDefaultsCurrencyText: String
    /// 时间
    @UserDefault(UserDefaultsTypeKeys.userDefaultsDateText.rawValue, defaultValue: Int64(Date().timeIntervalSince1970))
    static var userDefaultsDateText: Int64
    /// 分类
    @UserDefault(UserDefaultsTypeKeys.userDefaultsCategoryText.rawValue, defaultValue: "")
    static var userDefaultsCategoryText: String
    /// notes
    @UserDefault(UserDefaultsTypeKeys.userDefaultsNoteText.rawValue, defaultValue: "")
    static var userDefaultsNoteText: String
    
    
    

    

}
