//
//  SearchView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

open class SectionEmptyView: SuperView {
    // MARK: -  =====================lazyload=========================
    private var emptyImg = UIImageView().hidden(false)
    private var emptyLab = UILabel().text(L10n.allResultsAreNegative).hnFont(size: 12.h, weight: .regular).color(kkColorFromHex(kkMainTextColor)).centerAligned()
    
    // MARK: -  =====================Intial Methods===================
    open override func setUpUI() {
        self.addChildView([emptyImg,emptyLab])
        emptyImg.snp.makeConstraints { make in
            make.width.equalTo(150.h)
            make.height.equalTo(150.h)
            make.center.equalToSuperview()
        }
        emptyLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(20.h)
            make.top.equalTo(emptyImg.snp.bottom)
        }
        emptyImg.image(KiwiPublicPodResource.image(named: "sunmary_empty"))
    }
    // MARK: -  =======================actions========================
    open func refreshData(emptyImage:UIImage,emptyStr:String){
        emptyImg.image(emptyImage)
        emptyLab.text(emptyStr)
    }
    
    
    // MARK: -  =====================delegate=========================
    
}
