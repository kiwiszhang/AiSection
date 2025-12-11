//
//  UIButton+Extension.swift
//  MobileProgect
//
//  Created by csqiuzhi on 2019/4/30.
//  Copyright © 2019 于晓杰. All rights reserved.
//

import UIKit

//MARK: ----------创建方法-----------
extension UIButton {
    var BtnSize: CGSize {
        get {
            setNeedsDisplay()
            if titleLabel == nil || titleLabel!.text == nil {
                return CGSize.zero
            }
            return CGSize.init(width: UILabel.labWidth(titleLabel!.text!, font: titleLabel!.font), height: UILabel.labHeight(titleLabel!.text!, font: titleLabel!.font, width: width))
        }
    }
    
    /// 自定义按钮
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - titleFont: 标题文本尺寸
    ///   - titleColor: 标题颜色
    ///   - img: 背景图片
    ///   - selectImg: 选中背景图片
    ///   - bgColor: 背景色
    ///   - space: 图片文字间隔
    ///   - customBtnType: 图片朝向
    ///   - obj: 按钮响应对象
    ///   - methord: 按钮事件
    /// - Returns: 按钮
    class func creatBtn(title: String, titleFont: UIFont, titleColor: UIColor = .black, image: UIImage, selectImage: UIImage?, bgColor: UIColor = .clear, space: CGFloat, customBtnType: CustomButtonType, obj: AnyObject?, methord: Selector?) -> CustomButton {
        let btn = CustomButton.init(type: .custom).title(title, for: .normal).font(titleFont).backgroundColor(bgColor).image(image,for: .normal)
        btn.customBtnType = customBtnType
        btn.paddingSpace = space
        if selectImage != nil {
            btn.image(selectImage!, for: .selected)
        }
        if methord != nil && obj != nil {
            btn.addTarget(obj, action: methord!, for: .touchUpInside)
        }
        btn.sizeToFit()
        return btn
    }
    
    /// 倒计时按钮
    ///
    /// - Parameters:
    ///   - title: 重置标题
    ///   - waitTime: 等待时间
    func startBtn(title: String, waitTitle: String) {
        var timeOut = 60
        let timer = DispatchSource.makeTimerSource()
        timer.setEventHandler {
            if timeOut <= 0 {
                timer.cancel()
                DispatchQueue.main.sync(execute: {
                    self.title(title, for: .normal).enable(true)
                })
            } else {
                DispatchQueue.main.sync(execute: {
                    timeOut -= 1
                    let seconds = timeOut % 60
                    self.title("\(seconds)\(waitTitle)", for: .normal).enable(false)
                })
            }
        }
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        timer.resume()
    }
}
