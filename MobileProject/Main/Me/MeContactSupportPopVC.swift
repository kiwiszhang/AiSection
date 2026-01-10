//
//  HomePopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/13.
//

import UIKit

class MeContactSupportPopVC: SuperViewController {

    var dismissAction: (() -> Void)?
    private lazy var barView = PopTopView()
    private lazy var titleView = MeRow00ItemView()
    private lazy var contentView = MeRow01ItemView()
    private lazy var mailView = MeRow02ItemView()
    private lazy var titleStr = ""
    private lazy var contentStr = ""
    private lazy var mailStr = ""
    private lazy var confirmBtn = UILabel().text(L10n.confirm).hnFont(size: 18.h, weight: .medium).backgroundColor(kkColorFromHex(kkMainColor)).cornerRadius(14.h).enable(false).alpha(0.4).centerAligned().color(.white).onTap { [self] in
        if mailStr.isEmail {
            openMailApp()
            showAlertViewWithOutCancelButton(title: L10n.thankYouForYourFeedback,message: "", confirmButtonTitle:L10n.gotIt) { [self]confirmed in
                dismissAction?()
            }
        }else{
            showAlertViewWithOutCancelButton(title: "",message: L10n.textCorrectMail, confirmButtonTitle:L10n.ok) { [self] confirmed in
            }
        }
        MyLog("confirmBtn")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor(.white)
    }
    override func setUpUI() {
        view.addChildView([barView,titleView,contentView,mailView,confirmBtn])
        barView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(80.h)
        }
        titleView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(barView.snp.bottom)
            make.height.equalTo(105.h)
        }
        contentView.snp.makeConstraints { make in
            make.left.right.equalTo(titleView)
            make.top.equalTo(titleView.snp.bottom)
            make.height.equalTo(325.h)
        }
        
        mailView.snp.makeConstraints { make in
            make.left.right.equalTo(titleView)
            make.top.equalTo(contentView.snp.bottom)
            make.height.equalTo(105.h)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.height.equalTo(50.h)
            make.bottom.equalToSuperview().offset(-40.h)
        }
        confirmBtn.enable(false)
    }
    
    override func getData() {
        barView.delegate = self
        barView.addGradientBackground(colors: [kkColorFromHex("FFFFFF"),kkColorFromHex("E6EFFF")], direction: .bottomToTop)
        barView.updateData(title: L10n.contactSupport)
        barView.delegate = self
        titleView.delegate = self
        contentView.delegate = self
        mailView.delegate = self
    }
    
    func updataConfirmBtnStatus(title:String,content:String,mail:String){
        if !kkStringIsEmpty(title) && !kkStringIsEmpty(content) && !kkStringIsEmpty(mail) {
            confirmBtn.enable(true).alpha(1)
        }else{
            confirmBtn.enable(false).alpha(0.4)
        }
    }

    func openMailApp() {
        let email = mailStr
        let subject = titleStr
        let body = contentStr

        let urlString =
        "mailto:\(email)?subject=\(subject)&body=\(body)"

        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encoded) {
            UIApplication.shared.open(url)
        }
    }

    
}

// MARK: -  =======================PopTopViewDelegate========================
extension MeContactSupportPopVC:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
    func refreshSearchDataPop(updatedText: String){
    }
    
    func refreshSearchNoDataPop(){
    }
}
// MARK: -  =======================MeRow00ItemViewDelegate========================
extension MeContactSupportPopVC:MeRow00ItemViewDelegate {
    func meRow00ItemContent(content:String){
        titleStr = content
        updataConfirmBtnStatus(title: titleStr, content: contentStr, mail: mailStr)
    }
}
extension MeContactSupportPopVC:MeRow01ItemViewDelegate {
    func meRow01ItemContent(content:String){
        contentStr = content
        updataConfirmBtnStatus(title: titleStr, content: contentStr, mail: mailStr)
    }
}
extension MeContactSupportPopVC:MeRow02ItemViewDelegate {
    func meRow02ItemContent(content:String){
        mailStr = content
        updataConfirmBtnStatus(title: titleStr, content: contentStr, mail: mailStr)
    }
}


@objc protocol MeRow00ItemViewDelegate: AnyObject {
    func meRow00ItemContent(content:String)
}

class MeRow00ItemView: SuperView,UITextViewDelegate {
    weak var delegate: MeRow00ItemViewDelegate?
    private lazy var titleL = UILabel().text(L10n.title).hnFont(size: 14.h, weight: .medium).color(kkColorFromHex(kkSubTitleColor))
    private lazy var numberL = UILabel().text("0 / 50").hnFont(size: 14.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor)).rightAligned()
    private lazy var contentBg = UIView().backgroundColor(kkColorFromHex(kkWhiteTabColor)).cornerRadius(14.h)
    private lazy var contentV = PlaceholderTextView().hnFont(size: 16.h, weight: .regular).color(kkColorFromHex(kkMainTextColor)).backgroundColor(.clear).delegate(self)
    var maxCount = 50
    override func setUpUI() {
        self.addChildView([titleL,numberL,contentBg])
        contentBg.addChildView([contentV])
        numberL.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalToSuperview().offset(24.h)
            make.width.equalTo(100.w)
            make.height.equalTo(17.h)
        }
        titleL.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalTo(numberL.snp.left)
            make.height.equalTo(17.h)
            make.centerY.equalTo(numberL)
        }
        contentBg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalTo(titleL.snp.bottom).offset(14.h)
            make.bottom.equalToSuperview()
        }
        
        contentV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10.w)
            make.right.equalToSuperview().offset(-10.w)
            make.top.equalToSuperview().offset(8.h)
            make.bottom.equalToSuperview().offset(-12.h)
        }
    }
    
    override func getData() {
        numberL.text("0 / \(maxCount)")
        contentV.placeholder = L10n.pleaseEnterTheTitleInformation
        contentV.setupPlaceholder()
    }

    func textViewDidChange(_ textView: UITextView) {

        // ⚠️ 中文拼音输入中，不更新
        if let markedRange = textView.markedTextRange,
           textView.position(from: markedRange.start, offset: 0) != nil {
            return
        }

        let count = textView.text.count
        numberL.styledText(baseString: "\(count) / \(maxCount)", defaultAttributes: [
                    .foregroundColor: kkColorFromHex(kkMainColor),
                ], targets: [" / \(maxCount)"], attributes: [
                        [
                            .foregroundColor: kkColorFromHex(kkSubTitleColor),
                        ]
                ])

        // 超出最大长度（兜底保护）
        if count > maxCount {
            textView.text = String(textView.text.prefix(maxCount))
            numberL.styledText(baseString: "\(maxCount) / \(maxCount)", defaultAttributes: [
                        .foregroundColor: kkColorFromHex(kkMainColor),
                    ], targets: [" / \(maxCount)"], attributes: [
                            [
                                .foregroundColor: kkColorFromHex(kkSubTitleColor),
                            ]
                    ])
        }
        delegate?.meRow00ItemContent(content: textView.text)
    }
}

@objc protocol MeRow01ItemViewDelegate: AnyObject {
    func meRow01ItemContent(content:String)
}
class MeRow01ItemView: SuperView,UITextViewDelegate {
    weak var delegate: MeRow01ItemViewDelegate?
    private lazy var titleL = UILabel().text(L10n.describe).hnFont(size: 14.h, weight: .medium).color(kkColorFromHex(kkSubTitleColor))
    private lazy var numberL = UILabel().text("0 / 50").hnFont(size: 14.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor)).rightAligned()
    private lazy var contentBg = UIView().backgroundColor(kkColorFromHex(kkWhiteTabColor)).cornerRadius(14.h)
    private lazy var contentV = PlaceholderTextView().hnFont(size: 16.h, weight: .regular).color(kkColorFromHex(kkMainTextColor)).backgroundColor(.clear).delegate(self)
    var maxCount = 500
    override func setUpUI() {
        self.addChildView([titleL,numberL,contentBg])
        contentBg.addChildView([contentV])
        numberL.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalToSuperview().offset(24.h)
            make.width.equalTo(100.w)
            make.height.equalTo(17.h)
        }
        titleL.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalTo(numberL.snp.left)
            make.height.equalTo(17.h)
            make.centerY.equalTo(numberL)
        }
        contentBg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalTo(titleL.snp.bottom).offset(14.h)
            make.bottom.equalToSuperview()
        }
        
        contentV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10.w)
            make.right.equalToSuperview().offset(-10.w)
            make.top.equalToSuperview().offset(8.h)
            make.bottom.equalToSuperview().offset(-12.h)
        }
    }
    
    override func getData() {
        numberL.text("0 / \(maxCount)")
        contentV.placeholder = L10n.pleaseEnterTheContentYouNeed
        contentV.setupPlaceholder()
    }

    func textViewDidChange(_ textView: UITextView) {

        // ⚠️ 中文拼音输入中，不更新
        if let markedRange = textView.markedTextRange,
           textView.position(from: markedRange.start, offset: 0) != nil {
            return
        }

        let count = textView.text.count
        numberL.styledText(baseString: "\(count) / \(maxCount)", defaultAttributes: [
                    .foregroundColor: kkColorFromHex(kkMainColor),
                ], targets: [" / \(maxCount)"], attributes: [
                        [
                            .foregroundColor: kkColorFromHex(kkSubTitleColor),
                        ]
                ])

        // 超出最大长度（兜底保护）
        if count > maxCount {
            textView.text = String(textView.text.prefix(maxCount))
            numberL.styledText(baseString: "\(maxCount) / \(maxCount)", defaultAttributes: [
                        .foregroundColor: kkColorFromHex(kkMainColor),
                    ], targets: [" / \(maxCount)"], attributes: [
                            [
                                .foregroundColor: kkColorFromHex(kkSubTitleColor),
                            ]
                    ])
        }
        delegate?.meRow01ItemContent(content: textView.text)
    }
}

@objc protocol MeRow02ItemViewDelegate: AnyObject {
    func meRow02ItemContent(content:String)
}
class MeRow02ItemView: SuperView,UITextViewDelegate {
    weak var delegate: MeRow02ItemViewDelegate?
    private lazy var titleL = UILabel().text(L10n.mail).hnFont(size: 14.h, weight: .medium).color(kkColorFromHex(kkSubTitleColor))
    private lazy var numberL = UILabel().text("0 / 50").hnFont(size: 14.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor)).rightAligned().hidden(true)
    private lazy var contentBg = UIView().backgroundColor(kkColorFromHex(kkWhiteTabColor)).cornerRadius(14.h)
    private lazy var contentV = PlaceholderTextView().hnFont(size: 16.h, weight: .regular).color(kkColorFromHex(kkMainTextColor)).backgroundColor(.clear).delegate(self)
    var maxCount = 50000000000000000
    override func setUpUI() {
        self.addChildView([titleL,numberL,contentBg])
        contentBg.addChildView([contentV])
        numberL.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalToSuperview().offset(24.h)
            make.width.equalTo(100.w)
            make.height.equalTo(17.h)
        }
        titleL.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalTo(numberL.snp.left)
            make.height.equalTo(17.h)
            make.centerY.equalTo(numberL)
        }
        contentBg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalTo(titleL.snp.bottom).offset(14.h)
            make.bottom.equalToSuperview()
        }
        
        contentV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10.w)
            make.right.equalToSuperview().offset(-10.w)
            make.top.equalToSuperview().offset(8.h)
            make.bottom.equalToSuperview().offset(-12.h)
        }
    }
    
    override func getData() {
        contentV.placeholder = L10n.pleaseEnterYourEmailAddress
        contentV.setupPlaceholder()
    }

    func textViewDidChange(_ textView: UITextView) {

        // ⚠️ 中文拼音输入中，不更新
        if let markedRange = textView.markedTextRange,
           textView.position(from: markedRange.start, offset: 0) != nil {
            return
        }

        let count = textView.text.count
        numberL.styledText(baseString: "\(count) / \(maxCount)", defaultAttributes: [
                    .foregroundColor: kkColorFromHex(kkMainColor),
                ], targets: [" / \(maxCount)"], attributes: [
                        [
                            .foregroundColor: kkColorFromHex(kkSubTitleColor),
                        ]
                ])

        // 超出最大长度（兜底保护）
        if count > maxCount {
            textView.text = String(textView.text.prefix(maxCount))
            numberL.styledText(baseString: "\(maxCount) / \(maxCount)", defaultAttributes: [
                        .foregroundColor: kkColorFromHex(kkMainColor),
                    ], targets: [" / \(maxCount)"], attributes: [
                            [
                                .foregroundColor: kkColorFromHex(kkSubTitleColor),
                            ]
                    ])
        }
        delegate?.meRow02ItemContent(content: textView.text)
    }
}
