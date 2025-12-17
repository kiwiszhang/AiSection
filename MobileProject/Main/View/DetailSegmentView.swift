//
//  TopView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

@objc protocol DetailSegmentViewDelegate: AnyObject {
    func segmentClickIndex(index:Int)
}


class DetailSegmentView: SuperView{
    weak var delegate: DetailSegmentViewDelegate?
    // MARK: -  =====================lazyload=========================
    lazy var segmentedView = CapsuleSegmentedView(items: [], style: .defaultStyle)

    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        backgroundColor(.white)

        var style = CapsuleSegmentedStyle.defaultStyle
        style.selectedTextColor = kkColorFromHex(kkMainTitleColor)
        style.normalFont = UIFont.interOner(size: 14.h, weight: .regular)
        style.selectedFont = UIFont.interOner(size: 14.h, weight: .medium)
        
        segmentedView = CapsuleSegmentedView(
            items: [L10n.summarize, L10n.transcription],
            style: style
        )
        segmentedView.onValueChanged = { [self] index in
            delegate?.segmentClickIndex(index: index)
        }

        self.addSubview(segmentedView)
        segmentedView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10.h)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(260.w)
            $0.height.equalTo(36.h)
        }
        
    }
    override func getData() {
    }
    
    
    // MARK: -  =======================actions========================
    
    
}
