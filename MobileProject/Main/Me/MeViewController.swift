//
//  MeViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/11.
//

import UIKit
import StoreKit

struct SettingModel {
    var title: String = ""
    var imageIcon: UIImage
}

class MeViewController: SuperViewController {

    private lazy var itemList:[[SettingModel]] = []
    private lazy var itemHeaderList:[String] = []
    private var langSelected:LangItem? = nil
    private var TranscSelected:LangItem? = nil
    private var langContent:CenterLanguagePopVC = CenterLanguagePopVC()
    private var transcriptContent:CenterLanguagePopVC = CenterLanguagePopVC()
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(SettingItem00Cell.self).registerCells(SettingItem01Cell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SettingHeaderView.self).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(70.h).showsH(false).showsV(false)
    }()
    private lazy var topView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = kkColorFromHex(kkHomeBgColor)
        // Do any additional setup after loading the view.
    }
    
    override func setUpUI() {
        view.addChildView([topView,tableView])
        topView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(50.h)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
        }
    }
    
    override func getData() {
        itemList = HomeConfigData.getSettingData()
        itemHeaderList = [L10n.language,L10n.supportFeedback,L10n.legal]
        tableView.reloadData()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    

}

//MARK: ----------TableViewDelegateDataSource-----------
extension MeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let model = itemList[indexPath.section][indexPath.row]
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == itemList[indexPath.section].count - 1

        if indexPath.section == 0 {
            let cell = tableView.dequeueCell(SettingItem00Cell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.configure(with: model, isFirst: isFirst, isLast: isLast)
            return cell
        } else {
            let cell = tableView.dequeueCell(SettingItem01Cell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.configure(with: model, isFirst: isFirst, isLast: isLast)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                langContent.delegate = self
                let popup = PopupContainerViewController(contentVC: langContent, height: kkScreenHeight - 60.h)
                langContent.dismissAction = {
                    popup.dismissSelf()
                }
                self.present(popup, animated: false)
            } else if indexPath.row == 1 {
                transcriptContent.delegate = self
                let popup = PopupContainerViewController(contentVC: transcriptContent, height: kkScreenHeight - 60.h)
                transcriptContent.dismissAction = {
                    popup.dismissSelf()
                }
                self.present(popup, animated: false)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                } else {
                    if let url = URL(string: "https://apps.apple.com/app/id\(AppStoreId)?action=write-review"),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            } else if indexPath.row == 1 {
                if let url = URL(string: "https://apps.apple.com/app/id\(AppStoreId)?action=write-review") {
                    ShareManager.shared.shareURL(url,title: L10n.shareWithFriends)
                }
            } else if indexPath.row == 2 {
                let content = MeContactSupportPopVC()
//                content.delegate = self
                let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight - 60.h)
                content.dismissAction = {
                    popup.dismissSelf()
                }
                self.present(popup, animated: false)
            } else if indexPath.row == 3 {
                let content = MeOtherToolsPopVC()
//                content.delegate = self
                let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight - 60.h)
                content.dismissAction = {
                    popup.dismissSelf()
                }
                self.present(popup, animated: false)
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let webVC = WebViewController()
                webVC.webViewType = .ProtocolInfo
                self.navigationController?.pushViewController(webVC, animated: true)
            } else if indexPath.row == 1 {
                let webVC = WebViewController()
                webVC.webViewType = .UseTerms
                self.navigationController?.pushViewController(webVC, animated: true)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueHeaderFooter(SettingHeaderView.self)
        head.configure(with: itemHeaderList[section])
        return head
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let foot = tableView.dequeueHeaderFooter(SuperTableViewHeaderFooterView.self)
        return foot
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 50.h
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0.01
    }
}

// MARK: -  =======================CenterLanguagePopVCDelegate========================
extension MeViewController:CenterLanguagePopVCDelegate {
    func selectedLangitem(seletedItem: LangItem){
//        MyLog("selectedLangitem")
//        MyLog(seletedItem)
    }
    
    func selectedLangitem(seletedItem: LangItem,sender:CenterLanguagePopVC) {
        MyLog("selectedLangitem")
        MyLog(seletedItem)
        if sender == langContent {
            langSelected = seletedItem
            UserDefaultsTools.langSelected = seletedItem.title
            UserDefaultsTools.recordLangugasSelected = seletedItem.transLocalize
        }
        
        if sender == transcriptContent {
            TranscSelected = seletedItem
            UserDefaultsTools.fanyiYuYanTitle = seletedItem.title
        }
        tableView.reloadData()
    }
}

class SettingItem00Cell: SuperTableViewCell {
    private lazy var bgView = UIView().backgroundColor(.white)
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var moreImageV = UIImageView().image(Asset.meArrow.image).enable(true)
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)
    private lazy var subTitleL = UILabel().text("title").color(kkColorFromHex(kkSubTitleColor)).hnFont(size: 12.h, weight: .regular)
    private lazy var line = UIView().backgroundColor(kkColorFromHex("ECECED"))
    
    override func setUpUI() {
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addChildView([bgView])
        bgView.addChildView([iconImageV,moreImageV,titleL,subTitleL,line])
        
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.w)
            make.right.equalToSuperview().offset(-16.w)
            make.height.equalTo(70.h)
            make.center.equalToSuperview()
        }
        
        iconImageV.snp.makeConstraints { make in
            make.width.height.equalTo(36.h)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16.w)
        }
        
        moreImageV.snp.makeConstraints { make in
            make.width.height.equalTo(16.h)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16.w)
        }
        
        titleL.snp.makeConstraints { make in
            make.left.equalTo(iconImageV.snp.right).offset(10.w)
            make.right.equalTo(moreImageV.snp.left).offset(-8.w)
            make.top.equalToSuperview().offset(16.h)
            make.height.equalTo(17.h)
        }
        
        subTitleL.snp.makeConstraints { make in
            make.left.right.equalTo(titleL)
            make.top.equalTo(titleL.snp.bottom).offset(4.h)
            make.height.equalTo(15.h)
        }
        
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.w)
            make.right.equalToSuperview().offset(-16.w)
            make.height.equalTo(1)
            make.bottom.equalToSuperview().offset(0)
        }

    }
    
    func configure(with item: SettingModel,isFirst:Bool,isLast:Bool) {
        iconImageV.image(item.imageIcon)
        titleL.text(item.title)
        if isFirst {
            subTitleL.text(UserDefaultsTools.langSelected)
            bgView.cornerRadius(14.h, corners: [.topLeft,.topRight])
        }
        if isLast {
            subTitleL.text(UserDefaultsTools.fanyiYuYanTitle)
            line.hidden(true)
            bgView.cornerRadius(14.h, corners: [.bottomLeft,.bottomRight])
        }
    }
}

class SettingItem01Cell: SuperTableViewCell {
    private lazy var bgView = UIView().backgroundColor(.white)
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var moreImageV = UIImageView().image(Asset.meArrow.image).enable(true)
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)
    private lazy var line = UIView().backgroundColor(kkColorFromHex("ECECED"))
    
    override func setUpUI() {
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addChildView([bgView])
        bgView.addChildView([iconImageV,moreImageV,titleL,line])
        
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.w)
            make.right.equalToSuperview().offset(-16.w)
            make.height.equalTo(70.h)
            make.center.equalToSuperview()
        }
        
        iconImageV.snp.makeConstraints { make in
            make.width.height.equalTo(36.h)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16.w)
        }
        
        moreImageV.snp.makeConstraints { make in
            make.width.height.equalTo(16.h)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16.w)
        }
        
        titleL.snp.makeConstraints { make in
            make.left.equalTo(iconImageV.snp.right).offset(10.w)
            make.right.equalTo(moreImageV.snp.left).offset(-8.w)
            make.centerY.equalToSuperview()
            make.height.equalTo(17.h)
        }
        
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.w)
            make.right.equalToSuperview().offset(-16.w)
            make.height.equalTo(1)
            make.bottom.equalToSuperview().offset(0)
        }

    }
    
    func configure(with item: SettingModel,isFirst:Bool,isLast:Bool) {
        iconImageV.image(item.imageIcon)
        titleL.text(item.title)
        if isFirst {
            bgView.cornerRadius(14.h, corners: [.topLeft,.topRight])
        }
        if isLast {
            line.hidden(true)
            bgView.cornerRadius(14.h, corners: [.bottomLeft,.bottomRight])
        }
    }
}

class SettingHeaderView: SuperTableViewHeaderFooterView {
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .regular)
    override func setUpUI() {
        contentView.backgroundColor = .clear
        contentView.addChildView([titleL])
        titleL.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18.w)
            make.right.equalToSuperview().offset(-8.w)
            make.top.equalToSuperview().offset(20.h)
            make.height.equalTo(22.h)
        }
    }
    
    func configure(with titleStr: String) {
        titleL.text(titleStr)
    }
}
