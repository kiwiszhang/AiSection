//
//  TableViewCell.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/7/29.
//

import UIKit
import Localize_Swift

class UtitilTools{
    
    /// 判断是否为isDemo数据
    static func isDemoData(model:RecordingItem) -> Bool {
        return model.recordName == "isDemo" && model.updateTime == Int64.min && model.recordFolder == "isDemo" && model.createTime == Int64.min
    }
    static func isAddFolderData(model:FolderItem) -> Bool {
        return model.folderName == "isDemo" && model.createTime == Int64.min
    }
    
    /// 获取Recording/aaaa.m4a这种路径文件名
    static func relativePathFromDocuments(for fileURL: URL) -> String? {
        let fm = FileManager.default
        guard let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let docPath = documentsURL.standardizedFileURL.path
        let filePath = fileURL.standardizedFileURL.path

        guard filePath.hasPrefix(docPath) else { return nil }
        let relative = String(filePath.dropFirst(docPath.count + 1))
        return relative
    }
    
    /// 根据相对路径构建Documents  URL
    static func documentsURL(for relativePath: String) -> URL? {
        let fm = FileManager.default
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return docs.appendingPathComponent(relativePath)
    }

    /// 删除相对路径构建Documents  URL
    static func deleteRecording(relativePath: String) {
        guard let fileURL = documentsURL(for: relativePath) else { return }
        let fm = FileManager.default
        guard fm.fileExists(atPath: fileURL.path) else {
            MyLog("文件不存在: \(fileURL)")
            return
        }
        do {
            try fm.removeItem(at: fileURL)
            MyLog("已删除: \(fileURL.lastPathComponent)")
        } catch {
            MyLog("删除失败: \(error)")
        }
    }

    /// 删除TOS上面的数据
    static func deleteTOSObject(fileName:String,completion: @escaping (_ task:TOSTask<AnyObject>) -> Void){
        let credential = TOSCredential.init(accessKey: AKeyID02 + AKeyID01, secretKey: SAKey)
        let tosEndpoint = TOSEndpoint(urlString: TOS_ENDPOINT, withRegion: TOS_REGION)
        let config = TOSClientConfiguration(endpoint: tosEndpoint, credential: credential)
        let client = TOSClient.init(configuration: config)

        let input = TOSDeleteObjectInput()
        input.tosBucket = TOS_BUCKET
        input.tosKey = fileName
        let task = client.deleteObject(input)
        task.continueWith { t in
            completion(t)
            return nil
        }
    }
    
    /// 处理录音广播
    static func broadcast(handleStatus: Int,handleContent: String) {
        let state = HandleRecordingState(handleStatus: handleStatus, handleContent: handleContent)
        kkNotification_post(name: NotificationCenterKeys.kHandleRecordingState.rawValue, object: state)
    }
    
    /// Date转String 本地化转
    static func dateToString(_ date: Date, format: String = "MMM dd,yyyy") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // 保证英文月份能识别
        formatter.dateFormat = format                  // 格式
        return formatter.string(from: date)
    }

    /// 时间戳转时间格式
    static func formatTimestamp(_ timestamp: Int64) -> (date: String, time: String) {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let locale = Locale(identifier: "en_US_POSIX")

        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "MMM dd, yyyy"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = locale
        timeFormatter.dateFormat = "h:mm a"

        let dateText = dateFormatter.string(from: date)
        let timeText = timeFormatter.string(from: date)
            .replacingOccurrences(of: "AM", with: "am")
            .replacingOccurrences(of: "PM", with: "pm")

        return (dateText, timeText)
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
