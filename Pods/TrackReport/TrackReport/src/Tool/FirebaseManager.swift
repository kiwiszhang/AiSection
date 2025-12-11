import AppTrackingTransparency
import Combine
import FirebaseAnalytics
import FirebaseCore
import FirebaseRemoteConfig
import Foundation
import StoreKit

final class FirebaseManager {
    // MARK: - 单例与初始化
    static let shared = FirebaseManager()
    private init() { setupTrackingAuthorization() }

    // MARK: - 私有属性
    private var cancellables = Set<AnyCancellable>()
    private var remoteConfig: RemoteConfig?
    private let serialQueue = DispatchQueue(label: "com.firebase.manager.serial") // 专用串行队列确保线程安全
    private var isFetching = false
    private var pendingCompletions: [@convention(block) (Bool) -> Void] = [] // OC兼容的回调类型

    // MARK: - 公开方法
    /// 初始化Firebase配置
    func configure() {
        guard FirebaseApp.app() == nil else { return } // 避免重复初始化
        FirebaseApp.configure()
        // 配置RemoteConfig
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // 开发环境：立即获取；生产环境建议设为3600
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig?.configSettings = settings
    }
    
    func handleDeepLink(url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                if item.name == "utm_source" {
                    Analytics.setUserProperty(item.value ?? "apple", forName: "utm_source")
                } else if item.name == "utm_campaign" {
                    Analytics.setUserProperty(item.value ?? "none", forName: "utm_campaign")
                }
            }
        }
    }

    /// 获取RemoteConfig配置值
    /// - Parameters:
    ///   - key: 配置键名
    ///   - completion: 结果回调（主线程执行）
    func getRemoteConfig(key: String, completion: ((String?) -> Void)? = nil) {
        guard let remoteConfig = remoteConfig else {
            kLog("❌ RemoteConfig未初始化，请先调用configure()")
            DispatchQueue.main.async { completion?(nil) }
            return
        }

        fetchAndActivate { success in
            let value = success ? remoteConfig.configValue(forKey: key).stringValue : nil
            completion?(value)
        }
    }

    /// 提交交易事件（iOS 15+）
    @available(iOS 15.0, *)
    func logTransaction(_ transaction: Transaction) {
        Analytics.logTransaction(transaction)
        kLog("📊 已记录交易事件: \(transaction.productID)")
    }

    // MARK: - 私有方法
    /// 配置IDFA授权请求
    private func setupTrackingAuthorization() {
        guard #available(iOS 14, *) else { return }
        NotificationCenter.default.publisher(for: UIScene.didActivateNotification)
            .filter { _ in ATTrackingManager.trackingAuthorizationStatus == .notDetermined }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.requestTrackingAuthorization()
            }
            .store(in: &cancellables)
    }

    /// 请求IDFA授权
    @available(iOS 14, *)
    private func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { status in
            kLog("📱 IDFA授权结果: \(status.description)（原始值：\(status.rawValue)）")
            // 授权状态变化后可触发后续逻辑（如上报事件）
            Analytics.logEvent("idfa_authorization", parameters: [
                "status": status.rawValue,
                "description": status.description,
            ])
        }
    }

    /// 串行执行fetchAndActivate，支持多回调等待
    private func fetchAndActivate(completion: @escaping (Bool) -> Void) {
        // 包装回调为OC兼容类型，并确保在主线程执行
        let objcCompletion: @convention(block) (Bool) -> Void = { success in
            DispatchQueue.main.async { completion(success) }
        }

        serialQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            // 添加到等待队列
            self.pendingCompletions.append(objcCompletion)

            // 已有请求正在执行，等待即可
            guard !self.isFetching else {
                kLog("⏳ 已有RemoteConfig请求，等待队列长度: \(self.pendingCompletions.count)")
                return
            }

            // 执行请求
            self.performFetch()
        }
    }

    /// 执行实际的fetch操作
    private func performFetch() {
        guard let remoteConfig = remoteConfig else {
            handleCompletions(success: false)
            return
        }

        isFetching = true
        kLog("🚀 发起RemoteConfig请求，等待队列长度: \(pendingCompletions.count)")
        remoteConfig.fetchAndActivate { [weak self] result, error in
            guard let self = self else { return }
            let finalSuccess = error == nil
            if let error = error {
                kLog("❌ RemoteConfig fetchAndActivate失败: \(error.localizedDescription)")
            } else {
                kLog("✅ RemoteConfig fetchAndActivate成功，返回结果: \(result)")
            }
            
            self.handleCompletions(success: finalSuccess)
        }
    }

    /// 处理所有等待的回调
    private func handleCompletions(success: Bool) {
        serialQueue.async { [weak self] in
            guard let self = self else { return }

            // 复制并清空队列（串行队列中操作，确保线程安全）
            let completions = self.pendingCompletions
            self.pendingCompletions.removeAll()
            self.isFetching = false

            // 执行所有回调
            completions.forEach { $0(success) }
        }
    }
}

// MARK: - 扩展
@available(iOS 14, *)
private extension ATTrackingManager.AuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "未决策（用户尚未选择）"
        case .restricted: return "受限制（设备设置限制）"
        case .denied: return "已拒绝（用户不允许跟踪）"
        case .authorized: return "已授权（允许跟踪，可获取IDFA）"
        @unknown default: return "未知状态（\(rawValue)）"
        }
    }
}
