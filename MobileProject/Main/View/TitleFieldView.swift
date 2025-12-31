//
//  TabView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

@objc protocol TitleFieldViewDelegate: AnyObject {
    func refreshData(updatedText:String,selfView:TitleFieldView)
    func refreshNoData(selfView:TitleFieldView)
    func clickDowm(selfView:TitleFieldView)
}

class TitleFieldView: SuperView {
    weak var delegate: TitleFieldViewDelegate?
    private lazy var titleL = UILabel().text(L10n.audioFiles).hnFont(size: 14.h, weight: .medium).color(kkColorFromHex(kkSubTitleColor))
    private lazy var bgView = UIView().backgroundColor(kkColorFromHex(kkWhiteTabColor)).cornerRadius(14.h).onTap { [self] in
        delegate?.clickDowm(selfView: self)
    }
    lazy var prompTextField = UITextField().holder(L10n.fileName).delegate(self).backgroundColor(kkColorFromHex(kkWhiteTabColor)).enable(false)
    private lazy var downImg = UIImageView().image(Asset.floderDown.image).hidden(true).enable(true)
    override func setUpUI() {
        self.addChildView([titleL,bgView])
        titleL.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(17.h)
        }
        bgView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleL.snp.bottom).offset(14.h)
            make.height.equalTo(50.h)
        }
        bgView.addChildView([prompTextField])
        prompTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.w)
            make.right.equalToSuperview()
            make.top.height.equalToSuperview()
        }
        prompTextField.addSubView(downImg)
        downImg.snp.makeConstraints { make in
            make.width.height.equalTo(18.h)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16.w)
        }
    }
    
    func updateData(title:String,prompTitle:String,isShowDowm:Bool = false) {
        titleL.text(title)
        prompTextField.holder(prompTitle)
        downImg.hidden(!isShowDowm)
    }
    
    func updateContent(content:String){
        prompTextField.text(content)
    }
    
}

// MARK: -  =====================UITextFieldDelegate=========================
extension TitleFieldView:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 获取修改后的文本
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.isEmpty {
            delegate?.refreshNoData(selfView: self)
        } else {
            self.delegate?.refreshData(updatedText: updatedText,selfView: self)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            self.delegate?.refreshData(updatedText: text,selfView: self)
        } else {
            delegate?.refreshNoData(selfView: self)
        }
    }
}



