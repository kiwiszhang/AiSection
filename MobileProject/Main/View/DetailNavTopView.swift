//
//  TopView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit
import AVFoundation

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
    
    lazy var recordV = AudioPlayerView().backgroundColor(kkColorFromHex("E6EFFF")).cornerRadius(18.h).hidden(true)

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
        
        let directory = RecorderManager.shared.recordingsDirectory()
        let urlFile = URL(string:"\(directory.absoluteString)" + "567.m4a")!
        guard let fileURL = URL(string: urlFile.absoluteString) else {
            MyLog("无可用文件或路径错误")
            return
        }
        MyLog(urlFile)
        MyLog(fileURL)
//        recordV.loadAudio(url: fileURL)
        recordV.configure(url: fileURL, duration: audioDuration(url: fileURL))

        
    }
    func audioDuration(url: URL) -> TimeInterval {
        let asset = AVURLAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }

    override func getData() {
//        recordV.updateData()
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
