//
//  SearchView.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit

@objc protocol RefreshDataDelegate: AnyObject {
    func refreshData(updatedText:String)
    func refreshNoData()
}

class SearchView: SuperView {
    weak var delegate: RefreshDataDelegate?

    // MARK: -  =====================lazyload=========================
    private var searchImg = UIImageView().image(Asset.searchPop.image)
    lazy var prompTextField = UITextField().holder(L10n.searchNotesFolders).delegate(self).backgroundColor(.white)

    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        self.addChildView([searchImg,prompTextField])
        searchImg.snp.makeConstraints { make in
            make.width.height.equalTo(16.w)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(17.w)
        }
        
        prompTextField.snp.makeConstraints { make in
            make.left.equalTo(searchImg.snp.right).offset(6.w)
            make.right.equalToSuperview().offset(-10.w)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: -  =======================actions========================
    func getTitleData(propTitle:String) {
        prompTextField.holder(propTitle)
    }
    
    
    // MARK: -  =====================delegate=========================
    
}

// MARK: -  =====================UITextFieldDelegate=========================
extension SearchView:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 获取修改后的文本
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.isEmpty {
            delegate?.refreshNoData()
        } else {
            self.delegate?.refreshData(updatedText: updatedText)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            self.delegate?.refreshData(updatedText: text)
        } else {
            delegate?.refreshNoData()
        }
    }
}
