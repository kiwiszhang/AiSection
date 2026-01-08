//
//  TopView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit
import AVFoundation

@objc protocol ChatNavTopViewDelegate: AnyObject {
    func backClick()
    func moreClick()
    func shareClick()
}


class ChatNavTopView: SuperView{
    weak var delegate: ChatNavTopViewDelegate?
    var recordingItem:RecordingItem? = nil
    // MARK: -  =====================lazyload=========================
//    init(recordingItem:RecordingItem) {
//        super.init(frame: .zero)
//        self.recordingItem = recordingItem
//    }
//    @MainActor required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    private lazy var moreImage = UIImageView().image(Asset.chatHistory.image).enable(true).onTap { [self] in
        delegate?.moreClick()
    }

    private lazy var shareImage = UIImageView().image(Asset.chatRefrshu.image).enable(true).onTap { [self] in
        delegate?.shareClick()
    }


    private lazy var backImage = UIImageView().image(Asset.chatClose.image).enable(true).onTap { [self] in
        delegate?.backClick()
    }
    
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        backgroundColor = .clear
        self.addChildView([backImage,moreImage,shareImage])
        
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
        
        backImage.snp.makeConstraints { make in
            make.width.height.equalTo(18.h)
            make.centerY.equalTo(moreImage)
            make.left.equalToSuperview().offset(14.w)
        }

    }
    override func getData() {
//        recordV.updateData()
    }
    
    
    // MARK: -  =======================actions========================
    
    
}
