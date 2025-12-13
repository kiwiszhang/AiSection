//
//  CenterClickPopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

class CenterClickPopViewController: SuperViewController {

    var dismissAction: (() -> Void)?
    private lazy var centerV = UIView().backgroundColor(.white).cornerRadius(20.w)
    private lazy var topView = UIView().backgroundColor(.clear)
    private lazy var barView = PopTopView()
    private lazy var itemV0 = PopItemView().cornerRadius(14.h).backgroundColor(kkColorFromHex(kkWhiteTabColor)).onTap {
        MyLog("item00")
    }
    private lazy var itemV1 = PopItemView().cornerRadius(14.h).backgroundColor(kkColorFromHex(kkWhiteTabColor)).onTap {
        MyLog("item11")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func setUpUI() {
        view.backgroundColor(.clear)
        view.addChildView([topView,centerV])
        centerV.snp.makeConstraints { make in
            make.width.equalTo(361.w)
            make.height.equalTo(274.h)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-104.h)
        }
        
        topView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(centerV.snp.bottom).offset(0.h)
        }
        
        applyTransparentBlur(to: topView)

        centerV.addChildView([barView,itemV0,itemV1])
        barView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(80.h)
        }
        
        itemV0.snp.makeConstraints { make in
            make.width.equalTo(333.w)
            make.height.equalTo(70.h)
            make.centerX.equalToSuperview()
            make.top.equalTo(barView.snp.bottom).offset(4.h)
        }
        
        itemV1.snp.makeConstraints { make in
            make.width.equalTo(333.w)
            make.height.equalTo(70.h)
            make.top.equalTo(itemV0.snp.bottom).offset(14.h)
            make.left.equalTo(itemV0)
        }
        
        itemV0.updateData(itemType: 0)
        itemV1.updateData(itemType: 1)
        
    }

    override func getData() {
        barView.delegate = self
    }
    
    
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        // 判断点击是否在 contentVC.view 外
        if !centerV.frame.contains(location) {
            dismissAction?()
        }
    }
    
    
    func applyTransparentBlur(to view: UIView,
                              blurStyle: UIBlurEffect.Style = .systemUltraThinMaterial,
                              alpha: CGFloat = 0.02) {

        // 1. 系统超薄毛玻璃
        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.9
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)

        // 2. 添加透明蒙版，使毛玻璃更通透
        let overlay = UIView(frame: blurView.bounds)
        overlay.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.contentView.addSubview(overlay)
    }

}


class PopItemView: SuperView{
//    weak var delegate: FilterDateViewDelegate?
    // MARK: -  =====================lazyload=========================
    private lazy var  titleLab = UILabel().text(L10n.recording).color(kkColorFromHex(kkMainTitleColor)).fontSize(16.h, weight: .medium)
    private lazy var iconImage = UIImageView().image(Asset.type00.image).enable(true)
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        self.addChildView([titleLab,iconImage])
        
        iconImage.snp.makeConstraints { make in
            make.width.height.equalTo(40.h)
            make.centerY.equalToSuperview().offset(0.h)
            make.left.equalToSuperview().offset(16.w)
        }
        
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(iconImage.snp.right).offset(12.w)
            make.centerY.equalToSuperview().offset(0.h)
            make.right.equalToSuperview().offset(10.w)
            make.height.equalTo(20.h)
        }
    }
    override func getData() {

    }
    
    
    func updateData(itemType:Int){
        if itemType == 0 {
            titleLab.text(L10n.recording)
            iconImage.image(Asset.type00.image)
        }else{
            titleLab.text(L10n.audioFiles)
            iconImage.image(Asset.type01.image)
        }
    }
    // MARK: -  =======================actions========================
    
    
}

// MARK: -  =======================PopTopViewDelegate========================
extension CenterClickPopViewController:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
}
