//
//  ReportManager.swift
//  TrackReport
//
//  Created by 笔尚文化 on 2025/4/25.
//

import AdServices
import Foundation

class ReportManager {
    static let shared = ReportManager()
    private init() {}

    private var baseUrl: String {
        guard let host else {
            fatalError("请先调用config方法完成配置")
        }
        return host
    }

    private var baseAppId: String {
        guard let appId else {
            fatalError("请先调用config方法完成配置")
        }
        return appId
    }

    private var host: String?
    private var appId: String?

    @UserDefault(ReportManagerUserDefaultsKeys.uuid.rawValue)
    private var uuid: String?

    @UserDefault(ReportManagerUserDefaultsKeys.token.rawValue)
    private var token: String?

    func config(host: String, appId: String) {
        self.host = host
        self.appId = appId
        if let uuid {
            kLog("获取到uuid: \(uuid)")
        } else {
            uuid = UUID().uuidString
            kLog("未获取到uuid，创建: \(uuid!)")
        }
        if #available(iOS 14.3, *) {
            do {
                let token = try AAAttribution.attributionToken()
                self.token = token
                kLog("获取到归因token: \(token)")
            } catch {
                kLog("获取归因token失败: \(error)")
            }
        }
    }
}

extension ReportManager {
    private enum ReportManagerUserDefaultsKeys: String {
        case uuid = "ReportManagerUserDefaultsKeys_uuid"
        case token = "ReportManagerUserDefaultsKeys_token"
    }
    
    func registerUser() {
        // 1. 拼接完整的 URL
        let urlString = baseUrl + RequestPath.addUser
        guard let url = URL(string: urlString) else {
            kLog("无效的 URL: \(urlString)")
            return
        }
        // 2. 创建 URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // 3. 准备要发送的 JSON 数据
        var requestBody: [String: Any] = [
            "projectId": baseAppId,
            "platform": "ios",
            "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "1.0.0"
        ]
        if let uuid = uuid {
            requestBody["uuid"] = uuid
        }
        if let token = token {
            requestBody["token"] = token
        }
        // 4. 将字典转换为 JSON Data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            kLog("发送注册请求: \(urlString), 数据: \(requestBody)")
        } catch {
            kLog("JSON 序列化失败: \(error)")
            return
        }
        // 5. 发送网络请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 6. 处理响应
            if let error = error {
                kLog("注册请求失败: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                kLog("无效的响应")
                return
            }
            kLog("注册请求响应状态码: \(httpResponse.statusCode)")
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                kLog("注册请求响应内容: \(responseString)")
                if self.token == nil {
                    self.updateToken()
                }
            }
        }
        // 启动任务
        task.resume()
    }
    
    func subscription(with transactionId: String, page: TrackReportSubscriptionPage) {
        let urlString = baseUrl + RequestPath.eventReport
        guard let url = URL(string: urlString) else {
            kLog("无效的 URL: \(urlString)")
            return
        }
        // 2. 创建 URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // 3. 准备要发送的 JSON 数据
        var requestBody: [String: Any] = [
            "projectId": baseAppId,
            "platform": "ios",
            "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "1.0.0",
            "behaviorTypeId": "3",
            "behaviorContent": page.behaviorContent,
            "params": transactionId
        ]
        if let uuid = uuid {
            requestBody["uuid"] = uuid
        }
        if let token = token {
            requestBody["token"] = token
        }
        // 4. 将字典转换为 JSON Data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            kLog("上报订阅成功请求: \(urlString), 数据: \(requestBody)")
        } catch {
            kLog("JSON 序列化失败: \(error)")
            return
        }
        // 5. 发送网络请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 6. 处理响应
            if let error = error {
                kLog("订阅成功请求失败: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                kLog("无效的响应")
                return
            }
            kLog("订阅成功请求响应状态码: \(httpResponse.statusCode)")
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                kLog("订阅成功请求响应内容: \(responseString)")
            }
        }
        // 启动任务
        task.resume()
    }
    
    func customEvent(with eventId: String, behaviorContent: String? = nil) {
        let urlString = baseUrl + RequestPath.eventReport
        guard let url = URL(string: urlString) else {
            kLog("无效的 URL: \(urlString)")
            return
        }
        // 2. 创建 URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // 3. 准备要发送的 JSON 数据
        var requestBody: [String: Any] = [
            "projectId": baseAppId,
            "platform": "ios",
            "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "1.0.0",
            "behaviorTypeId": eventId
        ]
        if let behaviorContent {
            requestBody["behaviorContent"] = behaviorContent
        }
        if let uuid {
            requestBody["uuid"] = uuid
        }
        if let token {
            requestBody["token"] = token
        }
        // 4. 将字典转换为 JSON Data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            kLog("上报自定义事件请求: \(urlString), 数据: \(requestBody)")
        } catch {
            kLog("JSON 序列化失败: \(error)")
            return
        }
        // 5. 发送网络请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 6. 处理响应
            if let error = error {
                kLog("自定义事件请求失败: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                kLog("无效的响应")
                return
            }
            kLog("自定义事件请求响应状态码: \(httpResponse.statusCode)")
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                kLog("自定义事件请求响应内容: \(responseString)")
            }
        }
        // 启动任务
        task.resume()
    }
}

private
extension ReportManager {
    func updateToken() {
        if #available(iOS 14.3, *) {
            do {
                let token = try AAAttribution.attributionToken()
                self.token = token
                
                let urlString = baseUrl + RequestPath.updateToken
                guard let url = URL(string: urlString) else {
                    kLog("无效的 URL: \(urlString)")
                    return
                }
                // 2. 创建 URLRequest
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                // 3. 准备要发送的 JSON 数据
                var requestBody: [String: Any] = [
                    "projectId": baseAppId,
                    "platform": "ios",
                    "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "1.0.0"
                ]
                if let uuid = uuid {
                    requestBody["uuid"] = uuid
                }
                requestBody["token"] = token
                // 4. 将字典转换为 JSON Data
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
                    request.httpBody = jsonData
                    kLog("发送更新token请求: \(urlString), 数据: \(requestBody)")
                } catch {
                    kLog("JSON 序列化失败: \(error)")
                    return
                }
                // 5. 发送网络请求
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    // 6. 处理响应
                    if let error = error {
                        kLog("更新token请求失败: \(error)")
                        return
                    }
                    guard let httpResponse = response as? HTTPURLResponse else {
                        kLog("无效的响应")
                        return
                    }
                    kLog("更新token请求响应状态码: \(httpResponse.statusCode)")
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        kLog("更新token请求响应内容: \(responseString)")
                    }
                }
                // 启动任务
                task.resume()
                
            } catch {
                kLog("获取归因token失败: \(error)")
            }
        }
    }
}

private
extension TrackReportSubscriptionPage {
    var behaviorContent: String {
        switch self {
        case .subscriptionPage: "订阅页"
        case .guideSubscriptionPage: "引导订阅页"
        case .guideSubscriptionRetrievePage: "引导订阅挽回页"
        case .homePopPage: "首页弹窗"
        case .automaticRenewal: "自动续费"
        case .newSubscription: "新增订阅"
        }
    }
}
