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
let kkMainTitleColor = "#202124"
let kkMainTextColor = "#5B5F65;"
let kkSubTitleColor = "#8B8E94"
let kkSubTextColor = "#A4A9B1"
let kkIconColor = "#B4BBC9"

let kkWhiteTabColor = "#EEF0F4"
let kkWhiteSliceLineColor = "#ECECED"

let kkHomeBgColor = "#F2F4F8"
let kkRemindeColor = "#FECB32"
let kkErrorColor = "#FF3639"
let kkMainColor = "#2A78FE"



// MARK: - 常用标记
//本地存储
let GuidVersion = "GuidVersion"

var isPremiumUser: Bool {
    SubscriptionManager.shared.isValid
}
/// 营销消失按钮时间
var delayTime: Double {
    AppHelper.ABTest_delayTimeValue
}

func Localize_Swift_bridge(forKey:String,table:String,fallbackValue:String)->String {
    return forKey.localized(using: table);
}


