//
//  CustomTabBar.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/8/12.
//

import UIKit
class CustomTabBar: UITabBar {
    let centerButton = UIButton()
    let centerView = UIView().backgroundColor(.clear)
    let selectedImageV = UIImageView().image(Asset.addSelected.image).enable(true).hidden(false)
    lazy var unSelectedImageV = UIImageView().image(Asset.addUnselected.image).enable(true).hidden(true)
    lazy var timeView = centerRecordView().backgroundColor(kkColorFromHex(kkMainTextColor)).hidden(true)


    private let bgView = UIImageView(image: UIImage(named: "tabbar-button"))

    override init(frame: CGRect) {
        super.init(frame: frame)

        insertSubview(bgView, at: 0)
        bgView.contentMode = .scaleAspectFill

        addSubView(centerView)
        centerView.addChildView([unSelectedImageV,timeView,selectedImageV])

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgView.frame = bounds

        let buttonW: CGFloat = 60.h
        let buttonH: CGFloat = 60.h
        let tabBarWidth = bounds.width
        
        // 设置中间按钮位置（凸起）
        centerView.frame = CGRect(
            x: (tabBarWidth - buttonW) / 2,
            y: -30.h,
            width: buttonW,
            height: buttonH
        )
        centerView.cornerRadius(buttonH / 2)
        
        let size = centerView.bounds.size
        selectedImageV.frame = CGRect(origin: .zero, size: size)
        unSelectedImageV.frame = CGRect(origin: .zero, size: size)
        timeView.frame = CGRect(origin: .zero, size: size)


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
            let newPoint = centerView.convert(point, from: self)
            if centerView.point(inside: newPoint, with: event) {
                return centerView
            }
        }
        return super.hitTest(point, with: event)
    }
}

class centerRecordView: SuperView{
    // MARK: -  =====================lazyload=========================
    private lazy var  timeL = UILabel().text("00:00").color(.white).fontSize(12.h, weight: .regular).centerAligned()
    private lazy var centerImage = UIImageView().image(Asset.centerRecording.image).enable(true)
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        self.addChildView([timeL,centerImage])
        
        timeL.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(15.h)
            make.height.equalTo(15.h)
        }
        
        centerImage.snp.makeConstraints { make in
            make.width.height.equalTo(9.h)
            make.centerX.equalToSuperview()
            make.top.equalTo(timeL.snp.bottom).offset(3.h)
        }
        
    }
    override func getData() {

    }
    
    func updateDate(timeStr:String){
        timeL.text(timeStr)
    }
    // MARK: -  =======================actions========================
    
    
}
