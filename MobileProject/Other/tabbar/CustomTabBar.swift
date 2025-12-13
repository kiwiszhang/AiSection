//
//  CustomTabBar.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/8/12.
//

import UIKit
class CustomTabBar: UITabBar {
    let centerButton = UIButton()

    private let bgView = UIImageView(image: UIImage(named: "tabbar-button"))

    override init(frame: CGRect) {
        super.init(frame: frame)

        insertSubview(bgView, at: 0)
        bgView.contentMode = .scaleAspectFill


        // 配置中间按钮
        centerButton.setImage(UIImage(named: "addSelected"), for: .normal)
        centerButton.setImage(UIImage(named: "addUnselected"), for: .highlighted)
        centerButton.backgroundColor = .clear
        addSubview(centerButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgView.frame = bounds

        let buttonW: CGFloat = 56
        let buttonH: CGFloat = 60
        let tabBarWidth = bounds.width
        
        // 设置中间按钮位置（凸起）
        centerButton.frame = CGRect(
            x: (tabBarWidth - buttonW) / 2,
            y: -30,
            width: buttonW,
            height: buttonH
        )
        
        // 调整其他 TabBarItem 位置，给中间按钮留位置
        var index = 0
        let tabBarButtonWidth = tabBarWidth / 3
        for subview in subviews {
            if let control = subview as? UIControl, control != centerButton {
                var frame = control.frame
                frame.origin.x = tabBarButtonWidth * CGFloat(index)
                frame.size.width = tabBarButtonWidth
                control.frame = frame
                index += 1
                if index == 1 { index += 1 } // 跳过中间位置
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isHidden {
            let newPoint = centerButton.convert(point, from: self)
            if centerButton.point(inside: newPoint, with: event) {
                return centerButton
            }
        }
        return super.hitTest(point, with: event)
    }
}
