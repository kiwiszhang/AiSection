//
//  MBProgressHUD+Extension.swift
//  MobileProgect
//
//  Created by 于晓杰 on 2020/11/4.
//  Copyright © 2020 于晓杰. All rights reserved.
//

import UIKit
import KiwiPublicPod

extension MBProgressHUD {

    /// 只显示文字
    class func showMessage(_ message: String, view: UIView = kkKeyWindow()!) {
        showMessageView(message, imgName: nil, view: view)
    }
    
    /// 成功
    class func showSuccess(_ message: String = "", view: UIView = kkKeyWindow()!) {
        showMessageView(message, imgName: "success", view: view)
    }
    
    /// 失败
    class func showError(_ message: String = "", view: UIView = kkKeyWindow()!) {
        showMessageView(message, imgName: "error", view: view)
    }
    
    /// 警告
    class func showWarning(_ message: String = "", view: UIView = kkKeyWindow()!) {
        showMessageView(message, imgName: "warning", view: view)
    }
    
    /// HUD
    class func showHUD(_ message: String = "", view: UIView = kkKeyWindow()!) {
        showHUDView(message, view: view)
    }
    
    /// 进度
    class func showProgress(_ message: String = "", view: UIView = kkKeyWindow()!) -> MBProgressHUD? {
        return showProgressView(message, view: view)
    }
    
    /// 隐藏
    class func hideHUD(_ view: UIView = kkKeyWindow()!) {
        MBProgressHUD.hideAllHUDs(for: view, animated: true)
    }
}

extension MBProgressHUD {
    class private func showMessageView(_ text: String?, imgName: String?, view: UIView) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.detailsLabelText = text
        hud?.detailsLabelFont = UIFont.systemFont(ofSize: 14.h, weight: .black)
        if imgName != nil {
            hud?.customView = UIImageView.init(image: UIImage.init(named: "MBProgressHUD.bundle/\(imgName!)"))
        }
        hud?.mode = .customView
        hud?.hide(true, afterDelay: 2)
    }
    
    class private func showHUDView(_ text: String?, view: UIView) {
        if MBProgressHUD(for: view) != nil {
            return
        }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.detailsLabelText = text
        hud?.detailsLabelFont = UIFont.systemFont(ofSize: 14.h, weight: .black)
        hud?.removeFromSuperViewOnHide = true
        hud?.dimBackground = false
    }
    
    class private func showProgressView(_ text: String?, view: UIView) -> MBProgressHUD? {
        if MBProgressHUD(for: view) != nil {
            return nil
        }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.labelText = text
        hud?.labelFont = UIFont.systemFont(ofSize: 14.h, weight: .black)
        hud?.mode = .determinate
        hud?.removeFromSuperViewOnHide = true
        return hud
    }
}
