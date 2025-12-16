//
//  TopView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

@objc protocol TopViewDelegate: AnyObject {
    func refreshSearchData(updatedText: String)
    func refreshSearchNoData()
}

class TopView: SuperView{
    weak var delegate: TopViewDelegate?
    // MARK: -  =====================lazyload=========================
    private lazy var  titleLab = UILabel().text(L10n.myNotes).color(kkColorFromHex(kkMainTitleColor)).fontSize(26.h, weight: .bold)
    private lazy var vipImage = UIImageView().image(Asset.vipIcon.image).enable(true)
    private lazy var searchView = SearchView().backgroundColor(.white).cornerRadius(20.h)
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
//        self.backgroundColor()
        self.addChildView([titleLab,vipImage,searchView])
        
        vipImage.snp.makeConstraints { make in
            make.width.height.equalTo(30.h)
            make.top.equalToSuperview().offset(51.h)
            make.right.equalToSuperview().offset(-20.w)
        }
        
        titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.top.equalToSuperview().offset(48.h)
            make.right.equalTo(vipImage.snp.left).offset(10.w)
            make.height.equalTo(36.h)
        }
        
        searchView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.w)
            make.right.equalToSuperview().offset(-16.w)
            make.bottom.equalToSuperview()
            make.height.equalTo(40.h)
        }
        
    }
    override func getData() {
//        startEndView.delegate = self
        searchView.delegate = self
        addGradientBackground(colors: [kkColorFromHex("E6EFFF"),kkColorFromHex("F2F4F8")], direction: .topToBottom)
    }
    // MARK: -  =======================actions========================
    
    
}

// MARK: -  =======================RefreshDataDelegate========================
extension TopView:RefreshDataDelegate {
    func refreshData(updatedText: String) {
        delegate?.refreshSearchData(updatedText: updatedText)
    }
    
    func refreshNoData() {
        delegate?.refreshSearchNoData()
    }
}
