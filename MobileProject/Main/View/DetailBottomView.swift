//
//  TopView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

@objc protocol DetailBottomViewDelegate: AnyObject {
    func refreshDetailBottomData(updatedText:String)
    func refreshDetailBottomNoData()
    func bottomLeftClick()
    func bottomRightClick()
}


class DetailBottomView: SuperView{
    weak var delegate: DetailBottomViewDelegate?
    // MARK: -  =====================lazyload=========================
    private lazy var bgView = UIView().backgroundColor(.white).cornerRadius(12.h).border(width: 1, color: kkColorFromHex("DEE3EB"))

    private lazy var leftImage = UIImageView().image(Asset.chatIcon.image).enable(true).onTap { [self] in
        delegate?.bottomLeftClick()
    }
    private lazy var rightImage = UIImageView().image(Asset.chatAudio.image).enable(true).onTap { [self] in
        delegate?.bottomRightClick()
    }

    lazy var prompTextField = UITextField().holder(L10n.chatWithThisNote).delegate(self).backgroundColor(.white)

    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        backgroundColor(.white)
        self.addChildView([bgView])
        bgView.addChildView([leftImage,rightImage,prompTextField])
        
        bgView.snp.makeConstraints { make in
            make.width.equalTo(347.w)
            make.height.equalTo(48.h)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(19.h)
        }
        
        leftImage.snp.makeConstraints { make in
            make.width.height.equalTo(24.h)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(14.w)
        }

        rightImage.snp.makeConstraints { make in
            make.width.height.equalTo(36.h)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-6.w)
        }
        
        prompTextField.snp.makeConstraints { make in
            make.left.equalTo(leftImage.snp.right).offset(8.w)
            make.right.equalTo(rightImage.snp.left).offset(-8.w)
            make.centerY.equalToSuperview()
            make.height.equalTo(48.h)
        }
        
    }
    override func getData() {
    }
    
    
    // MARK: -  =======================actions========================
    
    
}

// MARK: -  =====================UITextFieldDelegate=========================
extension DetailBottomView:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 获取修改后的文本
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.isEmpty {
            delegate?.refreshDetailBottomNoData()
        } else {
            self.delegate?.refreshDetailBottomData(updatedText: updatedText)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            self.delegate?.refreshDetailBottomData(updatedText: text)
        } else {
            delegate?.refreshDetailBottomNoData()
        }
    }
}
