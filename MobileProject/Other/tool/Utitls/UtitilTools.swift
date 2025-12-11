//
//  TableViewCell.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/7/29.
//

import UIKit
import Localize_Swift

class UtitilTools{
    /// Date转String 本地化转
    static func dateToString(_ date: Date, format: String = "MMM dd,yyyy") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // 保证英文月份能识别
        formatter.dateFormat = format                  // 格式
        return formatter.string(from: date)
    }

    
    /// 订阅
    static func purchaseProduct(type:SubscriptionManager.SubscriptionType,completion: @escaping (Bool) -> Void) {
        if isPremiumUser {
            MBProgressHUD.showMessage(L10n.mbEnableBuy)
            return
        }

        DispatchQueue.main.async {
            Task {
                do {
                    try await SubscriptionManager.shared.purchase(type)
                    print("购买成功")
//                    MBProgressHUD.showMessage(L10n.mbBuySuccess)
                    completion(true)
                } catch SubscriptionManager.SubscriptionError.paymentCancelled {
                    print("用户取消了支付")
//                    MBProgressHUD.showMessage(L10n.mbBuyError)
                    completion(false)
                } catch SubscriptionManager.SubscriptionError.productNotFound {
                    print("找不到商品")
//                    MBProgressHUD.showMessage(L10n.mbBuyError)
                    completion(false)
                } catch SubscriptionManager.SubscriptionError.receiptValidationFailed {
                    print("订阅验证失败")
//                    MBProgressHUD.showMessage(L10n.mbBuyError)
                    completion(false)
                } catch SubscriptionManager.SubscriptionError.purchaseFailed(let error) {
                    print("购买失败，错误：\(error.localizedDescription)")
//                    MBProgressHUD.showMessage(L10n.mbBuyError)
                    completion(false)
                } catch {
                    print("未知错误：\(error)")
//                    MBProgressHUD.showMessage(L10n.mbBuyError)
                    completion(false)
                }
            }
        }
    }
    
}
