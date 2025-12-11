//
//  LanguageTool.swift
//  TrackReportDemo
//
//  Created by 笔尚文化 on 2025/5/21.
//

import Foundation

final class LanguageTool {
    static func localizedString(_ key: String) -> String {
        guard let bundle = trackReportBundle else {
            // 如果 TrackReport.bundle 本身就没加载成功，返回原始 Key 并打印警告
            print("TrackReport: Warning - TrackReport.bundle is nil, cannot find localized string for key: \(key)")
            return key
        }

        // 3. 尝试在 TrackReport.bundle 中查找与标准化系统语言对应的 .lproj 文件夹
        // Bundle.localizedString 方法会自动处理语言回退逻辑 (例如 zh-Hans -> zh -> Base -> en)
        // 所以我们直接调用 Bundle 的 localizedString 方法即可
        return bundle.localizedString(forKey: key, value: key, table: "Localizable")
    }

    private static var trackReportBundle: Bundle? = {
        // 获取当前 Framework 的 Bundle
        let frameworkBundle = Bundle(for: LanguageTool.self)

        // 在 Framework 的 Bundle 中查找 TrackReport.bundle 的路径
        guard let bundleURL = frameworkBundle.url(forResource: "TrackReport", withExtension: "bundle") else {
            // 如果找不到 Bundle，打印错误并返回 nil
            print("TrackReport: Error - Could not find TrackReport.bundle URL")
            return nil
        }

        // 根据路径创建 TrackReport.bundle 对象
        guard let bundle = Bundle(url: bundleURL) else {
            // 如果无法创建 Bundle 对象，打印错误并返回 nil
            print("TrackReport: Error - Could not create Bundle from URL: \(bundleURL)")
            return nil
        }

        return bundle.path(forResource: systemLanguageIdentifier, ofType: "lproj").flatMap(Bundle.init)
    }()

    private static var systemLanguageIdentifier: String {
        guard let preferredLanguage = Locale.preferredLanguages.first else { return "en" }
        return normalizeLanguageIdentifier(preferredLanguage)
    }

    private static func normalizeLanguageIdentifier(_ identifier: String) -> String {
        let components = identifier.components(separatedBy: "-")
        let baseLanguage = components[0]

        // 特殊处理中文和葡萄牙语等需要区分地区的语言
        if baseLanguage == "zh" {
            // 区分简体和繁体
            if identifier.contains("Hans") {
                return "zh-Hans"
            } else if identifier.contains("Hant") {
                return "zh-Hant"
            } else {
                // 如果没有 Hans 或 Hant，尝试根据地区判断，或者默认简体
                // 这里简化处理，如果包含任何中文标识但没有 Hans/Hant，默认简体
                return "zh-Hans"
            }
        }
        if baseLanguage == "pt" && components.count > 1 && components[1] == "BR" {
            return "pt-BR"
        }

        // 对于其他语言，只取基础语言部分 (例如 "en-US" -> "en")
        return baseLanguage
    }
    
    private init() {}
}
