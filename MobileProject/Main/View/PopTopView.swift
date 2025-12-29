//
//  PopTopView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/13.
//

import UIKit

@objc protocol PopTopViewDelegate: AnyObject {
    func popTopViewClose()
    
    @objc optional
    func refreshSearchDataPop(updatedText: String)
    @objc optional
    func refreshSearchNoDataPop()
    @objc optional
    func clickSearch()
}

class PopTopView: SuperView{
    weak var delegate: PopTopViewDelegate?
    // MARK: -  =====================lazyload=========================
    private lazy var  titleLab = UILabel().text(L10n.newNote).color(kkColorFromHex(kkMainTitleColor)).fontSize(20.h, weight: .bold)
    private lazy var closeImage = UIImageView().image(Asset.cancel.image).enable(true).onTap {
        self.delegate?.popTopViewClose()
    }
    private lazy var searchImageV = UIImageView().image(Asset.searchicon.image).enable(true).hidden(true).onTap { [self] in
//        self.delegate?.clickSearch?()
        searchV.hidden(false)
    }

    private lazy var searchV = SearchView().hidden(true).backgroundColor(.white).cornerRadius(17.h)
    
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        self.addChildView([titleLab,closeImage,searchImageV,searchV])
        
        closeImage.snp.makeConstraints { make in
            make.width.height.equalTo(34.h)
            make.top.equalToSuperview().offset(25.h)
            make.right.equalToSuperview().offset(-14.w)
        }
        
        searchImageV.snp.makeConstraints { make in
            make.width.height.equalTo(34.h)
            make.centerY.equalTo(closeImage)
            make.right.equalTo(closeImage.snp.left).offset(-20.w)
        }
        
        searchV.snp.makeConstraints { make in
            make.right.equalTo(closeImage.snp.left).offset(-20.w)
            make.centerY.equalTo(closeImage)
            make.height.equalTo(34.h)
            make.width.equalTo(202.w)
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
        searchV.delegate = self
    }
    
    // MARK: -  =======================actions========================
    func updateData(title:String,isSearch:Bool = false){
        titleLab.text(title)
        if isSearch {
            searchImageV.hidden(false)
        }
    }
    
    func updateSearchData(title:String){
        searchV.getTitleData(propTitle: title)
    }
    
}

// MARK: -  =======================RefreshDataDelegate========================
extension PopTopView:RefreshDataDelegate {
    func refreshData(updatedText:String){
        delegate!.refreshSearchDataPop!(updatedText: updatedText)
    }
    func refreshNoData(){
        delegate!.refreshSearchNoDataPop!()
    }
}
