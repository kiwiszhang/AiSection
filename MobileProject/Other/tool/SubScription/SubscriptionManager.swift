import Combine
import StoreKit
import KiwiPublicPod

class SubscriptionManager {
    static let shared = SubscriptionManager()
    private init() {
        listenForTransactions()
    }

    // MARK: - 订阅类型
    enum SubscriptionType: String, CaseIterable {
        case weekly = "com.yuehai.scanBills.weekly9.99.scanBills"
        case monthly = "com.yuehai.scanBills.month29.99.scanBills"
        case yearly = "com.yuehai.scanBills.year69.99.scanBills"
        
        case guid3DaysFreeWeekly = "com.yuehai.scanBills.3daysGuid.level1.scanBills"
        case retrieve3DaysFreeWeekly = "com.yuehai.scanBills.retrieve.weekly.level.scanBills"
        case retrieveMonthly = "com.yuehai.scanBills.retrieve.month29.99.scanBills"

        var localUnit: String {
            switch self {
                case .monthly: return L10n.Subscribe.month
                case .yearly: return L10n.Subscribe.year
                default: return L10n.Subscribe.week
            }
        }
    }

    // MARK: - 订阅状态
    enum SubscriptionStatus {
        case none
        case subscribed
        case expired
    }

    // MARK: - 错误类型
    enum SubscriptionError: LocalizedError {
        case productNotFound
        case purchaseFailed(Error)
        case receiptValidationFailed
        case paymentCancelled

        var errorDescription: String? {
            switch self {
            case .productNotFound:
                return "未找到商品"
            case let .purchaseFailed(error):
                return "购买失败: \(error.localizedDescription)"
            case .receiptValidationFailed:
                return "订阅验证失败"
            case .paymentCancelled:
                return "用户取消支付"
            }
        }
    }

    // MARK: - 商品定义

    struct ProductInfo {
        let product: Product?
        let subscriptionType: SubscriptionType
        var hasFreeTrial: Bool
        var trialPeriod: String?
        var localizedPrice: String
        var localizedSubscriptionInfo: String

        init?(product: Product?) {
            if let product = product {
                self.product = product

                // 根据产品ID确定订阅类型
                guard let type = SubscriptionType(rawValue: product.id) else {
                    return nil
                }
                subscriptionType = type
                localizedPrice = product.displayPrice

                if let intro = product.subscription?.introductoryOffer {
                    hasFreeTrial = intro.paymentMode == .freeTrial
                    trialPeriod = intro.period.localizedDescription
                } else {
                    hasFreeTrial = false
                    trialPeriod = nil
                }

                localizedSubscriptionInfo = L10n.Subscribe.Product.tips(localizedPrice, subscriptionType.localUnit)
                if hasFreeTrial {
                    localizedSubscriptionInfo = L10n.Subscribe.Product.freeTips(product.subscription?.introductoryOffer?.period.value ?? 3, localizedSubscriptionInfo)
                }
            } else {
                return nil
            }
        }

        init(product: Product?, subscriptionType: SubscriptionType, hasFreeTrial: Bool, trialPeriod: String?, localizedPrice: String, localizedSubscriptionInfo: String) {
            self.product = product
            self.subscriptionType = subscriptionType
            self.hasFreeTrial = hasFreeTrial
            self.trialPeriod = trialPeriod
            self.localizedPrice = localizedPrice
            self.localizedSubscriptionInfo = localizedSubscriptionInfo
        }
    }

    // MARK: - 属性
    var products: [String: ProductInfo] = [:]
    @Published private(set) var cachedSubscriptionStatus: SubscriptionStatus?
    private var lastCheckTime: Date?
    private let cacheValidDuration: TimeInterval = 10
    private var isRestoring: Bool = false

    // MARK: - 公共方法
    /// 加载所有商品
    func loadAllProducts() {
        Task {
            guard let storeProducts = try? await Product.products(for: SubscriptionType.allCases.map(\.rawValue)) else { return }
            let productInfos = storeProducts.compactMap { ProductInfo(product: $0) }
            products = Dictionary(uniqueKeysWithValues: productInfos.map { ($0.product!.id, $0) })
        }
    }
    
    /// 获取默认占位产品信息
    func loadDefaultProducts() -> [ProductInfo] {
        return [
            SubscriptionType.weekly,
            SubscriptionType.monthly,
            SubscriptionType.yearly,
        ].map { type in
            let defaultPrice: String
            switch type {
            case .monthly:
                defaultPrice = "$29.99"
            case .yearly:
                defaultPrice = "$69.99"
            default:
                defaultPrice = "$9.99"
            }

            let localizedSubscriptionInfo = L10n.Subscribe.Product.tips(defaultPrice, type.localUnit)

            return ProductInfo(
                product: nil,
                subscriptionType: type,
                hasFreeTrial: type == .weekly,
                trialPeriod: "\(type.localUnit)",
                localizedPrice: defaultPrice,
                localizedSubscriptionInfo: localizedSubscriptionInfo
            )
        }
    }
    /// 从缓存获取商品，没有找到就在线获取
    func fetchProductsWithCache(types productTypes: [SubscriptionType]) async throws -> [ProductInfo] {
        return try await productTypes.asyncMap {
            if let cachedProductInfo = products[$0.rawValue] {
                return cachedProductInfo
            }
            if let productInfo = try await fetchProducts(types: [$0]).first {
                return productInfo
            } else {
                throw SubscriptionError.productNotFound
            }
        }
    }

    /// 实时获取指定商品信息
    @discardableResult
    func fetchProducts(types productTypes: [SubscriptionType]) async throws -> [ProductInfo] {
        // 获取商品并构建ID到ProductInfo的映射
        let storeProducts = try await Product.products(for: productTypes.map(\.rawValue))
        let productInfos = storeProducts.compactMap { ProductInfo(product: $0) }
        let productMap = Dictionary(uniqueKeysWithValues: productInfos.map { ($0.product!.id, $0) })
        
        // 按传入的productTypes顺序构建结果数组
        let orderedProductInfos: [ProductInfo] = productTypes.compactMap { type in
            productMap[type.rawValue]
        }
        
        // 合并新旧缓存（保留原有缓存中不存在的产品）
        let newProducts = Dictionary(uniqueKeysWithValues: productInfos.map { ($0.product!.id, $0) })
        products.merge(newProducts) { _, new in new }
        
        return orderedProductInfos
    }

    /// 购买商品
    func purchase(_ type: SubscriptionType) async throws {
        var productToPurchase: Product?

        // 1. 尝试从缓存获取商品
        if let productInfo = products[type.rawValue] {
            productToPurchase = productInfo.product
        }

        // 2. 如果缓存未命中，尝试从 App Store 获取
        if productToPurchase == nil {
            do {
                let storeProducts = try await Product.products(for: [type.rawValue])
                if let fetchedProduct = storeProducts.first {
                    productToPurchase = fetchedProduct
                    if let fetchedProductInfo = ProductInfo(product: fetchedProduct) {
                        products[type.rawValue] = fetchedProductInfo
                    }
                } else {
                    throw SubscriptionError.productNotFound
                }
            } catch {
                throw SubscriptionError.purchaseFailed(error) // 或者可以定义一个更具体的错误类型
            }
        }

        // 3. 确保我们现在有商品可以购买
        guard let product = productToPurchase else {
            // 如果经过缓存查找和网络请求后仍然没有商品，则抛出错误
            throw SubscriptionError.productNotFound
        }

        // 4. 执行购买流程
        let result = try await product.purchase()

        switch result {
        case let .success(verification):
            switch verification {
            case let .verified(transaction):
                // 判断是否为首次购买该订阅组
                let isFirstPurchaseForGroup = transaction.purchaseDate.timeIntervalSince(transaction.originalPurchaseDate) < 60
                if isFirstPurchaseForGroup {
                    // 首次购买该订阅组
                    EventReport.subscription(with: transaction, isAutomaticRenewal: false)
                } else {
                    // 注意：这里可能是用户更改计划等操作，如果这些也需要单独上报，可以在此添加逻辑
                }

                // 完成交易并更新状态
                await transaction.finish()
                await updateSubscriptionStatus()
            case let .unverified(_, error):
                throw SubscriptionError.purchaseFailed(error)
            }
        case .userCancelled:
            throw SubscriptionError.paymentCancelled
        case .pending:
            break
        @unknown default:
            throw SubscriptionError.purchaseFailed(NSError(domain: "Unknown purchase result", code: -1))
        }
    }

    /// 恢复购买
    func restorePurchases() async throws {
        isRestoring = true
        defer {
            isRestoring = false
        }
        try await AppStore.sync()
        await updateSubscriptionStatus()

        if cachedSubscriptionStatus != .subscribed {
            throw SubscriptionError.receiptValidationFailed
        }
    }

    /// 检查订阅状态
    var isValid: Bool {
        if let lastCheck = lastCheckTime,
           let cachedStatus = cachedSubscriptionStatus,
           Date().timeIntervalSince(lastCheck) < cacheValidDuration {
            return cachedStatus == .subscribed
        }

        Task {
            await updateSubscriptionStatus()
        }
        
        let lastStatus = UserDefaults.standard.bool(forKey: UserDefaultsKeys.lastSubscriptionStatus)
        return lastStatus
    }
    /// 检查订阅状态
//    func isValid() async -> Bool {
//        if let lastCheck = lastCheckTime,
//           let cachedStatus = cachedSubscriptionStatus,
//           Date().timeIntervalSince(lastCheck) < cacheValidDuration {
//            return cachedStatus == .subscribed
//        }
//
//        await updateSubscriptionStatus()
//        let lastStatus = UserDefaults.standard.bool(forKey: UserDefaultsKeys.lastSubscriptionStatus)
//        return lastStatus
//    }

    // MARK: - 私有方法
    private func listenForTransactions() {
        Task.detached {
            for await result in Transaction.updates {
                await self.handleTransactionUpdate(result)
            }
        }
    }

    private func handleTransactionUpdate(_ result: VerificationResult<Transaction>) async {
        switch result {
        case let .verified(transaction):
            if transaction.revocationDate == nil {
                // 判断是否为续费事件
                // 条件：购买日期明显晚于原始购买日期
                let isRenewal = transaction.purchaseDate.timeIntervalSince(transaction.originalPurchaseDate) >= 60
                if isRenewal && !isRestoring {
                    // 在这里调用你的埋点上报函数，上报【自动续费】事件
                    EventReport.subscription(with: transaction, isAutomaticRenewal: true)
                } else {
                    // 这可能是首次购买的交易更新（虽然首次购买主要在 purchase 方法里处理，但更新流也可能收到）
                    // 或者是非常接近首次购买时间的更新，我们在这里通常不为首次购买上报，以避免重复
                }
                await updateSubscriptionStatus()
            }
            await transaction.finish()
        case .unverified:
            break
        }
    }

    private func updateSubscriptionStatus() async {
        var hasActiveSubscription = false
        var hasExpiredSubscription = false

        for await result in Transaction.currentEntitlements {
            if case let .verified(transaction) = result {
                if SubscriptionType(rawValue: transaction.productID) != nil {
                    if transaction.revocationDate == nil {
                        if let expirationDate = transaction.expirationDate {
                            if expirationDate > Date() {
                                hasActiveSubscription = true
                                break
                            } else {
                                hasExpiredSubscription = true
                            }
                        } else {
                            hasActiveSubscription = true
                            break
                        }
                    }
                }
            }
        }

        UserDefaults.standard.set(hasActiveSubscription, forKey: UserDefaultsKeys.lastSubscriptionStatus)

        lastCheckTime = Date()
        cachedSubscriptionStatus = hasActiveSubscription ? .subscribed : (hasExpiredSubscription ? .expired : SubscriptionManager.SubscriptionStatus.none)
    }
}

// MARK: - 扩展
private extension Product.SubscriptionPeriod {
    var localizedDescription: String {
        switch (unit, value) {
        case let (.day, days):
            return L10n.Subscribe.dDays(days)
        case let (.week, weeks):
            return L10n.Subscribe.dWeeks(weeks)
        case let (.month, months):
            return L10n.Subscribe.dMonths(months)
        case let (.year, years):
            return L10n.Subscribe.dYears(years)
        @unknown default:
            return ""
        }
    }
}

// MARK: - Constants
private enum UserDefaultsKeys {
    static let lastSubscriptionStatus = "last_subscription_status"
}
