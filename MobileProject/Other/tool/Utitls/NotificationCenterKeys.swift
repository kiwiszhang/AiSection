//
//  NotificationCenterKeys.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/8/8.
//

import UIKit

enum NotificationCenterKeys:String {
    // 导入聊天后天后刷新页面
    case kCreatNewWrappedReloadView = "NotificationCenterKeys_kCreatNewWrappedReloadView"
    /// 挽留购买页模态消失
    case kModalDidDismiss = "NotificationCenterKeys_kModalDidDismiss"
    /// 隐藏tabbar
    case kHideTabBar = "NotificationCenterKeys_hideTabBar"
    /// 添加消费记录后刷新消费页面
    case kReloadExpendsData = "NotificationCenterKeys_kReloadExpendsData"
    /// 添加报告后刷新报告页面
    case kReloadreportsData = "NotificationCenterKeys_kReloadreportsData"
    /// 裁剪玩关闭拍照页面
    case kCloseScanClick = "NotificationCenterKeys_kCloseScanClick"
    /// 裁剪页多张照片添加
    case kAddPicScanClick = "NotificationCenterKeys_kAddPicScanClick"
    /// 手动更新照片通知
    case kUpdateMerchantImage = "NotificationCenterKeys_kUpdateMerchantImage"
    /// 报告添加消费
    case kAddExpendsClick = "NotificationCenterKeys_kAddExpendsClick"
    /// 拍照权限通知
    case kHiddenTakePicCover = "NotificationCenterKeys_kHiddenTakePicCover"
    /// 删除数据更新view
    case kDeleteDataThenReloadView = "NotificationCenterKeys_kDeleteDataThenReloadView"
    /// 更新总结界面
    case kReloadSummaryData = "NotificationCenterKeys_kReloadSummaryData"
    /// 手动添加消费弹框里面的照片显示通知
    case kShowFullScreenPhoto = "NotificationCenterKeys_kShowFullScreenPhoto"
    /// 是否是报告页添加消费
    case kIsFromSearchMerchant = "NotificationCenterKeys_kIsFromSearchMerchant"

    
    
}

