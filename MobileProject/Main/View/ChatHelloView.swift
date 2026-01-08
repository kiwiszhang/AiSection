//
//  TopView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit
import AVFoundation



class ChatHelloView: SuperView{
    // MARK: -  =====================lazyload=========================
    private lazy var shareImage = UIImageView().image(Asset.chatHelloHeader.image).enable(true)
    private lazy var content = UILabel().text(L10n.personalAIAssistant).hnFont(size: 12.h, weight: .regular).color(kkColorFromHex(kkMainTextColor)).lines(0)
    
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        backgroundColor = .clear
        self.addChildView([shareImage,content])
        shareImage.snp.makeConstraints { make in
            make.width.equalTo(54.w)
            make.height.equalTo(15.h)
            make.top.equalToSuperview().offset(12.h)
            make.left.equalToSuperview().offset(12.w)
        }
        
        content.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12.w)
            make.right.equalToSuperview().offset(-12.w)
            make.bottom.equalToSuperview().offset(-12.h)
            make.top.equalTo(shareImage.snp.bottom).offset(4.h)
        }
        
    }
    override func getData() {
//        recordV.updateData()
    }
    
    
    // MARK: -  =======================actions========================
    
    
}
