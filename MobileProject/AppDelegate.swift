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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //内购代码
//        loadUserInfo()
        
        //应用分析
//        startAppInfo()
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

    }
}
