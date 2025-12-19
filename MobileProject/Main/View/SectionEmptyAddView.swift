//
//  SearchView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

@objc protocol SectionEmptyAddViewDelegate: AnyObject {
    func addANoteClick()
}

open class SectionEmptyAddView: SuperView {
    weak var delegate: SectionEmptyAddViewDelegate?
    // MARK: -  =====================lazyload=========================
    lazy var emptyView = SectionEmptyView()
    private lazy var dashBgV = DashedBorderView(cornerRadius: 12.h,lineWidth: 1,lineDashPattern: [3,3],strokeColor: kkColorFromHex(kkMainTextColor)).backgroundColor(kkColorFromHexWithAlpha("FFFFFF", 0.5)).onTap { [self] in
        delegate?.addANoteClick()
    }
    private lazy var titleL = UILabel().text(L10n.addANote).hnFont(size: 12.h, weight: .medium).color(.black).centerAligned()
    private lazy var addImageV = UIImageView().image(Asset.addFloders.image)
    // MARK: -  =====================Intial Methods===================
    open override func setUpUI() {
        self.addChildView([emptyView,dashBgV])
        emptyView.snp.makeConstraints { make in
            make.width.equalTo(150.h)
            make.height.equalTo(165.h)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        dashBgV.snp.makeConstraints { make in
            make.width.equalTo(148.w)
            make.height.equalTo(44.h)
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyView.snp.bottom).offset(44.h)
        }
        dashBgV.addChildView([titleL,addImageV])
        addImageV.snp.makeConstraints { make in
            make.width.height.equalTo(24.h)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-24.w)
        }
        titleL.snp.makeConstraints { make in
            make.height.equalTo(addImageV)
            make.centerY.equalTo(addImageV)
            make.left.equalToSuperview().offset(8.w)
            make.right.equalTo(addImageV.snp.right).offset(-8.w)
        }
    }
    // MARK: -  =======================actions========================
    open func refreshData(emptyImage:UIImage,emptyStr:String){
        emptyView.refreshData(emptyImage: emptyImage, emptyStr: emptyStr)
    }
    
    
    // MARK: -  =====================delegate=========================
    
}
