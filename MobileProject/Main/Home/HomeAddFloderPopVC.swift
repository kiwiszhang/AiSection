//
//  HomeFloderPopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/15.
//

import UIKit

@objc protocol HomeAddFloderPopVCDelegate: AnyObject {
    func addFloderSave(Floder:String)
}


class HomeAddFloderPopVC: SuperViewController {
    var flodreNameStr = ""
    weak var delegate: HomeAddFloderPopVCDelegate?
    var dismissAction: (() -> Void)?
    private lazy var topTitle: String = L10n.addFolder
    private lazy var barView = PopTopView()
    private lazy var textFiled = AddCategoryFieldView().enable(true)
    private lazy var saveBtn = UILabel().text(L10n.save).hnFont(size: 18.h, weight: .medium).backgroundColor(kkColorFromHexWithAlpha(kkMainColor, 0.3)).color(.white).centerAligned().cornerRadius(12.h).enable(false).onTap { [self] in
        if !kkStringIsEmpty(self.flodreNameStr) {
            delegate?.addFloderSave(Floder: self.flodreNameStr)
            dismissAction?()
        }
    }

    init(topTitle:String = L10n.addFolder) {
        super.init(nibName: nil, bundle: nil)
        self.topTitle = topTitle
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setUpUI() {
        view.addChildView([barView,textFiled,saveBtn])
        barView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(80.h)
        }
        
        textFiled.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50.h)
            make.top.equalTo(barView.snp.bottom).offset(9.h)
        }
        
        saveBtn.snp.makeConstraints { make in
            make.width.equalTo(335.w)
            make.height.equalTo(50.h)
            make.centerX.equalToSuperview()
            make.top.equalTo(textFiled.snp.bottom).offset(30.h)
        }
        
    }
    
    override func getData() {
        barView.delegate = self
        barView.addGradientBackground(colors: [kkColorFromHex("FFFFFF"),kkColorFromHex("E6EFFF")], direction: .bottomToTop)
        barView.updateData(title: topTitle)
        
        textFiled.delegate = self
        textFiled.addField.becomeFirstResponder()

    }
    
    func updataData(holderStr:String){
        textFiled.updateData(holderStr: holderStr)
    }
    
}


// MARK: -  =======================PopTopViewDelegate========================
extension HomeAddFloderPopVC:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
    
    func clickSearch() {
        MyLog("clickSearch")
    }
}

// MARK: -  =======================AddCategoryFieldViewDelegate========================
extension HomeAddFloderPopVC:AddCategoryFieldViewDelegate {
    @objc func updatedText(_ sender: AddCategoryFieldView,updatedText:String){
        flodreNameStr = updatedText
        saveBtn.backgroundColor(kkColorFromHex(kkMainColor)).enable(true)
    }
    @objc func noUpdatedText(_ sender: AddCategoryFieldView){
        flodreNameStr = ""
        saveBtn.backgroundColor(kkColorFromHexWithAlpha(kkMainColor, 0.3)).enable(false)
    }
    @objc func becomeFirstResponder(_ sender: AddCategoryFieldView){
        sender.addField.becomeFirstResponder()
    }
}


@objc protocol AddCategoryFieldViewDelegate: AnyObject {
    func updatedText(_ sender: AddCategoryFieldView,updatedText:String)
    func noUpdatedText(_ sender: AddCategoryFieldView)
    func becomeFirstResponder(_ sender: AddCategoryFieldView)
}

class AddCategoryFieldView: SuperView, UITextFieldDelegate {
    weak var delegate: AddCategoryFieldViewDelegate?
    // MARK: -  =====================lazyload=========================
    private var Bgview = UIView().backgroundColor(kkColorFromHex("F3F4F6")).cornerRadius(6.w)
    lazy var addField = UITextField().holder(L10n.newFolderName).delegate(self).onTap { [self] in
        delegate?.becomeFirstResponder(self)
    }
    // MARK: -  =====================Intial Methods===================
    override func setUpUI() {
        self.addChildView([Bgview])
        Bgview.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        Bgview.addChildView([addField])
        addField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10.w)
            make.height.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: -  =======================actions========================
    func updateData(holderStr:String){
        addField.holder(holderStr)
    }
    
    // MARK: -  =====================delegate=========================
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 获取修改后的文本
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        // 限制最大长度为 30
        if updatedText.count > 30 {
            return false
        }
        if updatedText.isEmpty {
            MyLog("没有输入")
            delegate?.noUpdatedText(self)
        } else {
            MyLog("当前输入: \(updatedText)")
            delegate?.updatedText(self, updatedText: updatedText)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            MyLog("结束编辑，有输入: \(text)")
            delegate?.updatedText(self, updatedText: text)
        } else {
            MyLog("结束编辑，没有输入")
            delegate?.noUpdatedText(self)
        }
    }
}

