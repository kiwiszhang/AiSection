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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateLanguageUI), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        // 替换系统 TabBar
        let customTabBar = CustomTabBar()
        setValue(customTabBar, forKey: "tabBar")
        
        // 添加子控制器
        viewControllers = [
            createNav(HomeViewController(), title: "Home", image: Asset.homeUnSelected.image, selectedImage: Asset.homeSelected.image),
            createNav(MeViewController(), title: "Me", image: Asset.meUnSelected.image, selectedImage: Asset.meSelected.image),
        ]
        
        // 中间按钮点击
        if let customTabBar = tabBar as? CustomTabBar {
            customTabBar.centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
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
        print("中间按钮点击了")
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



