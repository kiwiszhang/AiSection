//
//  VersionTool.swift
//  MobileProject
//
//  Created by Yu on 2025/4/5.
//

import KiwiPublicPod

struct VersionTool {
    private static let userDefaults = UserDefaults.standard
    /// 存储当前显示的版本号
    static func saveCurrentVersion() {
        userDefaults.set(kkAppVersion, forKey: GuidVersion)
    }
    /// 判断是否需要显示引导图
    static func shouldShowGuide() -> Bool {
        guard let lastShownVersion = userDefaults.string(forKey: GuidVersion) else {
            // 首次安装
            return true
        }
        return kkAppVersion.compare(lastShownVersion, options: .numeric) == .orderedDescending
    }

}
