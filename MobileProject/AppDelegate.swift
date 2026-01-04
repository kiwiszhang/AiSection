//
//  AppDelegate.swift
//  MobileProject
//
//  Created by Yu on 2025/4/5.
//

import UIKit
import FirebaseCore
import FirebaseRemoteConfig
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var allowLandscapeRight = false
    let persistenceController = PersistenceController.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //应用分析
        startAppInfo()

        IQKeyboardManagerAction()
        
        //内购代码
//        loadUserInfo()
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if allowLandscapeRight {
            return .landscapeRight
        }
        return .portrait
    }
}
extension AppDelegate {
    //获取购买列表购买状态
    private func loadUserInfo() {

    }
    //Firebase
    private func startAppInfo() {

        if UserDefaultsTools.isFirstInstallApp {
            let item00 = RecordingItemRequest(updateTime: Int64.min, recordType: 0, recordPath: "isDemo.m4a", recordName: "isDemo", recordFolder: "isDemo", recordFolderId:UUID().uuidString, isFavorite: false, createTime: Int64.min, transcriptionData: nil)
            do{
                try! RecordingItemStore.shared.addRecordingItem(item00)
            }
            
            let itemFolder00 = FolderItemRequest(folderName: "isDemo", recordFolderId: UUID().uuidString, createTime: Int64.min)
            let itemFolder01 = FolderItemRequest(folderName: L10n.allNotes, recordFolderId: UUID().uuidString, createTime: Int64.max)
            do{
                try! FolderItemStore.shared.addFolderItem(itemFolder01)
                try! FolderItemStore.shared.addFolderItem(itemFolder00)
            }

            UserDefaultsTools.isFirstInstallApp = false
        }
    }
    
    func IQKeyboardManagerAction(){
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.resignOnTouchOutside = true

        // 关键配置：确保能处理所有窗口
        IQKeyboardManager.shared.keyboardDistance = 20
        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        
        // 允许处理所有类型的视图
        IQKeyboardManager.shared.playInputClicks = true
        IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder = true
    }
}
