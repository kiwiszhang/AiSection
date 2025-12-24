//
//  CustomTabBarController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/8/13.
//

import VisionKit
import UIKit
import Vision
import Localize_Swift


class MainTabBarController: UITabBarController {
    let customTabBar = CustomTabBar()
    private var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateLanguageUI), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        // 替换系统 TabBar
        setValue(customTabBar, forKey: "tabBar")
        
        // 添加子控制器
        viewControllers = [
            createNav(HomeViewController(), title: "Home", image: Asset.homeUnSelected.image, selectedImage: Asset.homeSelected.image),
            createNav(MeViewController(), title: "Me", image: Asset.meUnSelected.image, selectedImage: Asset.meSelected.image),
        ]
        
        // 中间按钮点击
        if let customTabBar = tabBar as? CustomTabBar {
//            customTabBar.centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
            customTabBar.centerView.onTap { [self] in
                centerButtonTapped()
            }
        }
    }
    
    private func createNav(_ rootVC: UIViewController, title: String, image: UIImage, selectedImage: UIImage) -> UINavigationController {
        let nav = CustomNavigationController(rootViewController: rootVC)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
        nav.tabBarItem.selectedImage = selectedImage.withRenderingMode(.alwaysOriginal)
        return nav
    }
    @objc func updateLanguageUI() {
        // 遍历每个 tab
        for (index, item) in (self.tabBar.items ?? []).enumerated() {
            switch index {
            case 0:
                item.title = "Home"  // 这里用你本地化的字符串
            case 1:
                item.title = "Me"
            default:
                break
            }
        }
        
        // 如果是 UINavigationController 包含的 ViewController，需要更新 root view controller 的标题
        if let navControllers = self.viewControllers as? [UINavigationController] {
            for nav in navControllers {
                nav.topViewController?.title = nav.topViewController?.title // 可以根据需要更新标题
            }
        }
    }
    @objc private func centerButtonTapped() {
        MyLog("中间按钮点击了")
        
        let manager = RecorderManager.shared
        if manager.isRecording {
            
            let content = CenterRecordPopViewController()
            let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight - 60.h)
            content.dismissAction = { [self] in
                popup.dismissSelf()
                centerStatus()
            }
            self.present(popup, animated: false)
            
        } else {
            
            customTabBar.selectedImageV.hidden(true)
            customTabBar.unSelectedImageV.hidden(false)
            customTabBar.timeView.hidden(true)
            
            let content = CenterClickPopViewController()
            let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight,isMiddle: true)
            content.dismissAction = { [self] in
                popup.dismissSelf()
                centerStatus()
            }
            present(popup, animated: false)
        }
    }
    
    func centerStatus(){
        if RecorderManager.shared.isRecording {
            customTabBar.selectedImageV.hidden(true)
            customTabBar.unSelectedImageV.hidden(true)
            customTabBar.timeView.hidden(false)
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self else { return }

                let duration = RecorderManager.shared.recordingDuration()
                let text = String(format: "%02d:%02d",
                                  Int(duration) / 60,
                                  Int(duration) % 60)
                
                customTabBar.timeView.updateDate(timeStr: text)

            }
            RunLoop.main.add(timer!, forMode: .common)
        }else{
            customTabBar.selectedImageV.hidden(false)
            customTabBar.unSelectedImageV.hidden(true)
            customTabBar.timeView.hidden(true)
        }
    
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        UIView.setAnimationsEnabled(false)
        DispatchQueue.main.async {
            UIView.setAnimationsEnabled(true)
        }
    }
}

/// 设置tabbar push和pop回来选中颜色不会变
func setupTabBarAppearance() {
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .white
    // 隐藏顶部的分隔线
    appearance.shadowColor = .clear   // iOS 13+
    appearance.shadowImage = UIImage() // 保险
    // 未选中状态
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
        .foregroundColor: kkColorFromHex("#A4A9B1")
    ]
    // 选中状态
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
        .foregroundColor: kkColorFromHex("#202124")
    ]
    UITabBar.appearance().standardAppearance = appearance
    if #available(iOS 15.0, *) {
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

///状态栏设置
extension MainTabBarController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return selectedViewController?.customStatusBarStyle ?? StatusBarManager.shared.style
//        return .darkContent
    }

    override var prefersStatusBarHidden: Bool {
        return selectedViewController?.customStatusBarHidden ?? StatusBarManager.shared.isHidden
    }

    override var childForStatusBarStyle: UIViewController? {
        return selectedViewController
    }
}



