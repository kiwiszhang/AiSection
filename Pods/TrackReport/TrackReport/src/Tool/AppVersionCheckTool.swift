//
//  AppVersionCheckTool.swift
//  TrackReportDemo
//
//  Created by 笔尚文化 on 2025/5/21.
//

import Foundation

struct AppVersionCheckTool {
    static func checkAppVersionWithAutoPopAlter(complete: ((String?) -> Void)? = nil) {
        let urlString = "https://itunes.apple.com/lookup?bundleId=\((Bundle.main.bundleIdentifier ?? "com.tayue.collage"))&t=\(Date().timeIntervalSince1970)"
        guard let url = URL(string: urlString) else {
            kLog("无效的 URL: \(urlString)")
            complete?(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)) { data, response, error in
            if let error = error {
                kLog("获取app版本请求失败: \(error)")
                complete?(nil)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                kLog("无效的响应")
                complete?(nil)
                return
            }
            kLog("获取app版本请求响应状态码: \(httpResponse.statusCode)")
            if
                let data,
                let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let results = jsonResponse["results"] as? [Any],
                let appInfo = results.first as? [String: Any],
                let appVersion = appInfo["version"] as? String,
                let appUpdateDesc = appInfo["releaseNotes"] as? String,
                let appUrl = appInfo["trackViewUrl"] as? String,
                let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            {
                complete?(appVersion)
                if appVersion.compare(currentAppVersion, options: .numeric) == .orderedDescending {
                    kLog("有新APP版本: \(appVersion)\n更新内容:\n\(appUpdateDesc)")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(
                            title: LanguageTool.localizedString("New version found"),
                            message: appUpdateDesc,
                            preferredStyle: .alert
                        )
                        if appUpdateDesc.hasPrefix("[") {
                            kLog("APP需要提示更新")
                            let cancelAction = UIAlertAction(
                                title: LanguageTool.localizedString("Cancel"),
                                style: .default
                            )
                            let okAction = UIAlertAction(
                                title: LanguageTool.localizedString("OK"),
                                style: .default
                            ) { _ in
                                if let url = URL(string: appUrl), UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            alert.addAction(cancelAction)
                            alert.addAction(okAction)
                            if let currentVC = currentViewController() {
                                currentVC.present(alert, animated: true)
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    currentViewController()?.present(alert, animated: true)
                                }
                            }
                        } else if appUpdateDesc.hasPrefix("【") {
                            kLog("APP需要强制更新")
                            let okAction = UIAlertAction(
                                title: LanguageTool.localizedString("OK"),
                                style: .default
                            ) { _ in
                                if let url = URL(string: appUrl), UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            alert.addAction(okAction)
                            if let currentVC = currentViewController() {
                                currentVC.present(alert, animated: true)
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    currentViewController()?.present(alert, animated: true)
                                }
                            }
                        } else {
                            kLog("APP不需要提示更新")
                        }
                    }
                } else {
                    kLog("无新APP版本")
                }
            } else {
                kLog("获取app版本请求结果解析失败")
                complete?(nil)
            }
        }
        // 启动任务
        task.resume()
    }
}

private
extension AppVersionCheckTool {
    /// 获取当前正在显示控制器
    static func currentViewController() -> UIViewController? {
        var resultVC = _topViewController(kKeyWindow()?.rootViewController)
        while resultVC?.presentedViewController != nil {
            resultVC = _topViewController((resultVC?.presentedViewController)!
            )
        }
        return resultVC
    }
    
    static func kKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
                .first(where: { $0.isKeyWindow })
        } else {
            return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }
    }
    
    static func _topViewController(_ vc: UIViewController?) -> UIViewController? {
        if let vc = vc as? UINavigationController {
            return self._topViewController(vc.topViewController)
        } else if let vc = vc as? UITabBarController {
            return self._topViewController(vc.selectedViewController)
        } else {
            return vc
        }
    }
}
