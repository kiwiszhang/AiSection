//
//  UIWindow+Extension.swift
//  MobileProgect
//
//  Created by csqiuzhi on 2019/5/20.
//  Copyright © 2019 于晓杰. All rights reserved.
//

import UIKit
import KiwiPublicPod

extension UIWindow {
    /// 切换根控制器
    private func switchRootViewController(_ newRootVC: UIViewController, animated: Bool = true) {
        guard animated else {
            rootViewController = newRootVC
            return
        }

        UIView.transition(with: self,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
            self.rootViewController = newRootVC
        })
    }
    
    func showInitialViewController() {
        if AppHelper.isShowGuidView {
//            AppHelper.isShowGuidView = false
            // 显示引导页
//            showGuidViewController(index: 0)
            showTreeViewController()
        } else {
            // 进入主页
            if isPremiumUser {
                showMainViewController()
            }else{
                showTreeViewController()
            }
        }
    }
    
    func showMainOrBuyWithPermium(){
//        if isShowPay {
//            if isPremiumUser {
                showMainViewController()
//            }else{
//                showInitialViewController()
//            }
//        }else{
//            showInitialViewController()
//        }
    }
    
    /// 显示主界
    func showMainViewController(){
        let tabVC = MainTabBarController()
        switchRootViewController(tabVC)
    }
    /// 显示试用界面
    func showTreeViewController() {
//        EventReport.subscriptionSuccess(from: .event3232)
        self.rootViewController = CustomNavigationController(rootViewController: HomeViewController())
    }
    /// 显示挽留界面
    func showRetrieveViewController() {
        self.rootViewController = CustomNavigationController(rootViewController: MeViewController())
    }
//    /// 显示选择货币界面
//    func showFirstViewController() {
//        self.rootViewController = CustomNavigationController(rootViewController: FirstViewController())
//    }
//    /// 显示功能引导页
//    func showActionGuidViewController() {
//        self.rootViewController = CustomNavigationController(rootViewController: ActionViewController())
//    }
//    
//    /// 显示引导页
//    func showGuidViewController(index: Int = 0) {
//        let pages: [NewGuidePage] = [
//            NewGuidePage(index: 0, resource: Files.Videos.newGuid0Mp4.name, titleStr: L10n.newGuid0Title, detailStr: L10n.newGuid0Detail),
//            NewGuidePage(index: 1, resource: Files.Videos.newGuid1Mp4.name, titleStr: L10n.newGuid1Title, detailStr: L10n.newGuid1Detail),
//            NewGuidePage(index: 2, resource: Files.Videos.newGuid2Mp4.name, titleStr: L10n.newGuid2Title, detailStr: L10n.newGuid2Detail),
//            NewGuidePage(index: 3, resource: Files.Videos.newGuid3Mp4.name, titleStr: L10n.newGuid3Title, detailStr: L10n.newGuid3Detail),
//        ]
//        let guidVC = NewGuidNormalViewController(newGuidePageModel: pages[index])
//        switchRootViewController(CustomNavigationController(rootViewController: guidVC))
//    }
    
    /// 显示启动页
    func showLanchViewController(){
        let vc = MainTabBarController()
        self.rootViewController = vc
    }
}


