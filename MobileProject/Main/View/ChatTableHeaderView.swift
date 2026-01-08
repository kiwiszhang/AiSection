//
//  TopView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit
import AVFoundation

@objc protocol ChatTableHeaderViewDelegate: AnyObject {
    func segmentTableHeaderViewClickIndex(index:Int)
    func allNoteClick()
    func tableHeaderPlayClick()
}


class ChatTableHeaderView: SuperView{
    weak var delegate: ChatTableHeaderViewDelegate?
    var recordingItem:RecordingItem? = nil
    
    private lazy var bgView = UIImageView().image(Asset.chatBg.image)
    private lazy var animationImage = UIImageView()
    private lazy var helloLable = UILabel().text("text").backgroundColor(kkColorFromHex("F2F4F8")).cornerRadius(14.h)
    private lazy var typeLable = ChatTypeView().border(width: 1, color: kkColorFromHex("F2F4F8")).cornerRadius(14.h)
    // MARK: -  =====================lazyload=========================
//    init(recordingItem:RecordingItem) {
//        super.init(frame: .zero)
//        self.recordingItem = recordingItem
//    }
//    @MainActor required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        
        self.addChildView([bgView,helloLable,typeLable])
        
        bgView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(270.h)
        }
        
        bgView.addSubView(animationImage)
        animationImage.snp.makeConstraints { make in
            make.width.equalTo(100.w)
            make.height.equalTo(116.h)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(106.h)
        }
        
        helloLable.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24.w)
            make.right.equalToSuperview().offset(-24.w)
            make.top.equalTo(bgView.snp.bottom).offset(-30.h)
            make.height.equalTo(140.h)
        }
        
        typeLable.snp.makeConstraints { make in
            make.width.equalTo(180.w)
            make.height.equalTo(50.h)
            make.right.equalToSuperview().offset(-24.w)
            make.top.equalTo(helloLable.snp.bottom).offset(12.h)
        }
        
        animationImage.loadGif(name: "chat_animation")
    }
    
    override func getData() {
//        if recordingItem?.recordType == 0 {
//            typeLable.updateData(title: (recordingItem?.recordName!)!, sTitle: L10n.recording, icon: Asset.type00.image)
//        }else{
//            typeLable.updateData(title: (recordingItem?.recordName!)!, sTitle: L10n.audioFiles, icon: Asset.type01.image)
//        }
    }
    
    func updateData(item:RecordingItem){
        recordingItem = item
        if recordingItem?.recordType == 1 {
            typeLable.updateData(title: (recordingItem?.recordName!)!, sTitle: L10n.recording, icon: Asset.type00.image)
        }else{
            typeLable.updateData(title: (recordingItem?.recordName!)!, sTitle: L10n.audioFiles, icon: Asset.type01.image)
        }
    }
    
    
    // MARK: -  =======================actions========================
    
}
