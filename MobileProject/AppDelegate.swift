//
//  AppDelegate.swift
//  MobileProject
//
//  Created by Yu on 2025/4/5.
//

import UIKit
import FirebaseCore
import FirebaseRemoteConfig

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var allowLandscapeRight = false
    let persistenceController = PersistenceController.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //应用分析
        startAppInfo()

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
            let item00 = RecordingItemRequest(updateTime: Int64.min, recordType: 0, recordPath: "isDemo.m4a", recordName: "isDemo", recordFolder: "isDemo", recordFolderId: -1, isFavorite: false, createTime: Int64.min)
            do{
                try! RecordingItemStore.shared.addRecordingItem(item00)
            }
            
            let itemFolder00 = FolderItemRequest(folderName: "isDemo", recordFolderId: -1, createTime: Int64.min)
            do{
                try! FolderItemStore.shared.addFolderItem(itemFolder00)
            }

            UserDefaultsTools.isFirstInstallApp = false
        }
        
    }
}
