//
//  Common.swift
//  MobileProgect
//
//  Created by csqiuzhi on 2019/4/30.
//  Copyright © 2019 于晓杰. All rights reserved.
//

import UIKit
import Localize_Swift;
// MARK: - APP 配置相关
let kkMainColor = "#06D094"
let kkMainTextColor = "#202124"
let kkTextSubColor = "5B5F65"
let kkLightColor = "E0E2E5"

let kkSeparatorStr = "**.._&_&7=="

// MARK: - 常用标记
//本地存储
let GuidVersion = "GuidVersion"

let isShowPay = true

var isPremiumUser: Bool {
    SubscriptionManager.shared.isValid
}
/// 营销消失按钮时间
//var delayTime: Double {
//    AppHelper.ABTest_delayTimeValue
//}

func Localize_Swift_bridge(forKey:String,table:String,fallbackValue:String)->String {
    return forKey.localized(using: table);
}


