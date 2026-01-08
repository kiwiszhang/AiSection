//
//  TopView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit
import AVFoundation


class ChatTypeView: SuperView{
    // MARK: -  =====================lazyload=========================
    private lazy var moreImage = UIImageView().image(Asset.type00.image).enable(true).border(width: 1, color: kkColorFromHex(kkSubTextColor)).cornerRadius(15.h)
    private lazy var titleL = UILabel().text("").hnFont(size: 12.h, weight: .medium).color(kkColorFromHex(kkMainTitleColor))
    private lazy var subTitle = UILabel().text("").hnFont(size: 10.h, weight: .regular).color(kkColorFromHex(kkSubTextColor))
    
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        backgroundColor = .clear
        self.addChildView([titleL,moreImage,subTitle])
        
        moreImage.snp.makeConstraints { make in
            make.width.height.equalTo(30.h)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10.w)
        }
        
        titleL.snp.makeConstraints { make in
            make.left.equalTo(moreImage.snp.right).offset(8.w)
            make.right.equalToSuperview().offset(-8.w)
            make.top.equalTo(moreImage.snp.top)
            make.height.equalTo(15.h)
        }
        
        subTitle.snp.makeConstraints { make in
            make.left.right.equalTo(titleL)
            make.bottom.equalTo(moreImage.snp.bottom)
            make.height.equalTo(12.h)
        }

    }
    override func getData() {
//        recordV.updateData()
    }
    
    func updateData(title:String,sTitle:String,icon:UIImage){
        titleL.text(title)
        subTitle.text(sTitle)
        moreImage.image(icon)
    }
    
    
    // MARK: -  =======================actions========================
    
    
}
