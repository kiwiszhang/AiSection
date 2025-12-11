//
//  EventReport.swift
//  teleprompter
//
//  Created by 笔尚文化 on 2025/4/29.
//

import Foundation
import TrackReport
import StoreKit

struct EventReport {
    enum CustomEvent: String {
        ///进入引导页（最后一张）
        case event3231 = "3231"
        ///进入引导订阅页）
        case event3232 = "3232"
        ///进入引导订阅挽留页
        case event3233 = "3233"
        ///进入首页
        case event3234 = "3234"
        ///单张扫描创建报告
        case event3235 = "3235"
        ///多张扫描创建报告
        case event3236 = "3236"
        ///手动创建报告
        case event3237 = "3237"
        ///进入总结页-月看板
        case event3238 = "3238"
        ///进入总结页-年看板
        case event3239 = "3239"
        ///进入总结页-报告看板
        case event3240 = "3240"
        ///进入设置页
        case event3241 = "3241"
        ///设置页修改货币
        case event3242 = "3242"
        ///设置页订阅模块点击
        case event3243 = "3243"
    }
    
    static func config() {
        TrackReportKit.config(appId: "65")
    }
    
    static func registerUser() {
#if !DEBUG
        TrackReportKit.registerUser()
#endif
    }
    
    static func subscription(with transaction: Transaction, isAutomaticRenewal: Bool) {
#if !DEBUG
        TrackReportKit.subscription(with: transaction, page: isAutomaticRenewal ? .automaticRenewal : .newSubscription)
#endif
    }
    
    static func subscriptionSuccess(from event: CustomEvent, behaviorContent: String? = nil) {
#if !DEBUG
        TrackReportKit.customEvent(with: event.rawValue, behaviorContent: behaviorContent)
#endif
    }
    
    static func reportFeatureRequest(with desc: String) {
#if !DEBUG
//        TrackReportKit.customEvent(with: CustomEvent.featureRequest.rawValue, behaviorContent: desc)
#endif
    }
    
    static func checkAppVersion() async -> String? {
#if !DEBUG
        return await withCheckedContinuation { continuation in
            TrackReportKit.checkAppVersionWithAutoPopAlter {
                continuation.resume(returning: $0)
            }
        }
#else
        return "\(Int.max)"
#endif
    }
}


extension EventReport {
    enum ABTestType: String, CaseIterable {
        case delayTime
        case retrieve
//        case homeAlert = "31"
    }
    
    static func getABTestConfig(with type: ABTestType) async -> String? {
        #if DEBUG
            return nil
        #else
            return await withCheckedContinuation { continuation in
                TrackReportKit.getAppConfig(with: type.rawValue) {
                    continuation.resume(returning: $0)
                }
            }
        #endif
    }
}
