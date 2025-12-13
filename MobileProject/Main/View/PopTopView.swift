//
//  PopTopView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/13.
//

import UIKit

@objc protocol PopTopViewDelegate: AnyObject {
    func popTopViewClose()
}

class PopTopView: SuperView{
    weak var delegate: PopTopViewDelegate?
    // MARK: -  =====================lazyload=========================
    private lazy var  titleLab = UILabel().text(L10n.newNote).color(kkColorFromHex(kkMainTitleColor)).fontSize(20.h, weight: .bold)
    private lazy var closeImage = UIImageView().image(Asset.cancel.image).enable(true).onTap {
        self.delegate?.popTopViewClose()
    }
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        self.addChildView([titleLab,closeImage])
        
        closeImage.snp.makeConstraints { make in
            make.width.height.equalTo(34.h)
            make.top.equalToSuperview().offset(25.h)
            make.right.equalToSuperview().offset(-14.w)
        }
        
        titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14.w)
            make.top.equalToSuperview().offset(30.h)
            make.right.equalTo(closeImage.snp.left).offset(-10.w)
            make.height.equalTo(24.h)
        }
    }
    override func getData() {
        addGradientBackground(colors: [kkColorFromHex("FFFFFF"),kkColorFromHex("E6EFFF")], direction: .bottomToTop)
    }
    
    // MARK: -  =======================actions========================
    func updateData(title:String){
        titleLab.text(title)
    }
    
}
