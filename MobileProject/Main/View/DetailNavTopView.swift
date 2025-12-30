//
//  TopView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

@objc protocol DetailNavTopViewDelegate: AnyObject {
    func backClick()
    func moreClick()
    func shareClick()
    func favoriteClick()
}


class DetailNavTopView: SuperView{
    weak var delegate: DetailNavTopViewDelegate?
    // MARK: -  =====================lazyload=========================
    private lazy var moreImage = UIImageView().image(Asset.moreAction.image).enable(true).onTap { [self] in
        delegate?.moreClick()
    }

    private lazy var shareImage = UIImageView().image(Asset.shareTop.image).enable(true).onTap { [self] in
        delegate?.shareClick()
    }

    private lazy var favoriteImage = UIImageView().image(Asset.unfavorite.image).enable(true).onTap { [self] in
        delegate?.favoriteClick()
    }

    private lazy var backImage = UIImageView().image(Asset.backArrow.image).enable(true).onTap { [self] in
        delegate?.backClick()
    }
    
    lazy var recordV = DetailRecordView().backgroundColor(kkColorFromHex("E6EFFF")).cornerRadius(18.h).hidden(true)

    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        backgroundColor(kkColorFromHexWithAlpha("317DFF", 0.16))
        self.addChildView([backImage,moreImage,shareImage,favoriteImage,recordV])
        
        moreImage.snp.makeConstraints { make in
            make.width.height.equalTo(24.h)
            make.top.equalToSuperview().offset(54.h)
            make.right.equalToSuperview().offset(-20.w)
        }
        
        shareImage.snp.makeConstraints { make in
            make.width.height.equalTo(24.h)
            make.top.equalTo(moreImage)
            make.right.equalTo(moreImage.snp.left).offset(-18.w)
        }
        
        favoriteImage.snp.makeConstraints { make in
            make.width.height.equalTo(24.h)
            make.top.equalTo(shareImage)
            make.right.equalTo(shareImage.snp.left).offset(-18.w)
        }
        
        backImage.snp.makeConstraints { make in
            make.width.height.equalTo(18.h)
            make.centerY.equalTo(moreImage)
            make.left.equalToSuperview().offset(14.w)
        }

        recordV.snp.makeConstraints { make in
            make.left.equalTo(backImage.snp.right).offset(20.w)
            make.centerY.equalTo(backImage)
            make.right.equalTo(favoriteImage.snp.left).offset(-19.w)
            make.height.equalTo(36.h)
        }
        
    }
    override func getData() {
        recordV.updateData()
    }
    
    func updateFavorite(isFavorite:Bool){
        if isFavorite {
            favoriteImage.image(Asset.favoriteTop.image)
        }else{
            favoriteImage.image(Asset.unfavorite.image)
        }
    }
    
    // MARK: -  =======================actions========================
    
    
}
