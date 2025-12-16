//
//  TopView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

@objc protocol NavTopViewDelegate: AnyObject {
    func backClick()
    func moreClick()
    func refreshSearchData(updatedText: String)
    func refreshSearchNoData()
}


class NavTopView: SuperView{
    weak var delegate: NavTopViewDelegate?
    // MARK: -  =====================lazyload=========================
    private lazy var  titleLab = UILabel().text(L10n.myNotes).color(kkColorFromHex(kkMainTitleColor)).fontSize(20.h, weight: .bold)
    private lazy var moreImage = UIImageView().image(Asset.moreAction.image).enable(true).onTap { [self] in
        delegate?.moreClick()
    }
    private lazy var backImage = UIImageView().image(Asset.backArrow.image).enable(true).onTap { [self] in
        delegate?.backClick()
    }
    private lazy var searchView = SearchView().backgroundColor(.white).cornerRadius(20.h)
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
//        self.backgroundColor()
        self.addChildView([titleLab,backImage,moreImage,searchView])
        
        moreImage.snp.makeConstraints { make in
            make.width.height.equalTo(24.h)
            make.top.equalToSuperview().offset(54.h)
            make.right.equalToSuperview().offset(-20.w)
        }
        
        backImage.snp.makeConstraints { make in
            make.width.height.equalTo(18.h)
            make.centerY.equalTo(moreImage)
            make.left.equalToSuperview().offset(14.w)
        }
        
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(backImage.snp.right).offset(16.w)
            make.centerY.equalTo(backImage)
            make.right.equalTo(moreImage.snp.left).offset(10.w)
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
        searchView.delegate = self
    }
    
    func updateData(title:String){
        searchView.getTitleData(propTitle: title)
    }
    func updateTitle(title:String){
        titleLab.text(title)
    }
    
    // MARK: -  =======================actions========================
    
    
}

// MARK: -  =======================RefreshDataDelegate========================
extension NavTopView:RefreshDataDelegate {
    func refreshData(updatedText: String) {
        delegate?.refreshSearchData(updatedText: updatedText)
    }
    
    func refreshNoData() {
        delegate?.refreshSearchNoData()
    }
}
