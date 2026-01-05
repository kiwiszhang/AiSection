//
//  CenterClickPopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit
import Localize_Swift

@objc class LangItem:NSObject {
    var title: String = ""
    var subTitle: String = ""
    var localize: String = ""
    var isSelected: Bool = false
    init(title: String,subTitle: String,localize: String,isSelected: Bool) {
        self.title = title
        self.subTitle = subTitle
        self.localize = localize
        self.isSelected = isSelected
    }
}

@objc protocol CenterLanguagePopVCDelegate:AnyObject {
    func selectedLangitem(seletedItem: LangItem)
    @objc optional
    func selectedLangitem(seletedItem: LangItem,sender:CenterLanguagePopVC)
}

class CenterLanguagePopVC: SuperViewController {
    weak var delegate: CenterLanguagePopVCDelegate?
    var itemList:[LangItem] = []
    var selecedRow = 0

    var dismissAction: (() -> Void)?
    private lazy var barView = PopTopView()

    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(SetLangPopCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(60.h).showsH(false)
    }()
    
    private lazy var saveBtn = UILabel().text(L10n.save).hnFont(size: 18.h, weight: .medium).color(.white).backgroundColor(kkColorFromHex(kkMainColor)).centerAligned().cornerRadius(14.h).onTap { [self] in
        MyLog("saveBtn")
        let selectedItem = itemList[selecedRow]
        delegate?.selectedLangitem(seletedItem: selectedItem)
        delegate?.selectedLangitem?(seletedItem: selectedItem, sender: self)
        dismissAction?()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setUpUI() {
        view.addChildView([barView,tableView,saveBtn])

        barView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(80.h)
        }
        
        saveBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.bottom.equalToSuperview().offset(-40.h)
            make.height.equalTo(50.h)
        }

        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(barView.snp.bottom)
            make.bottom.equalTo(saveBtn.snp.top).offset(-40.h)
        }
        
    }

    override func getData() {
        barView.delegate = self
        barView.updateData(title: L10n.language,isSearch: true)
        barView.updateSearchData(title: L10n.searchLanguage)

        let language = Localize.currentLanguage()
        let item00 = LangItem(title: "English", subTitle: L10n.english, localize: "en_us", isSelected: false)
        let item01 = LangItem(title: "Português (Brasil)", subTitle: L10n.portuguese, localize: "pt-BR", isSelected: false)
//        let item02 = LangItem(title: "Español (México)", subTitle: L10n.spanish, localize: "es-MX", isSelected: false)
//        let item03 = LangItem(title: "Türkçe", subTitle: L10n.turkish, localize: "tr", isSelected: false)
//        let item04 = LangItem(title: "Français", subTitle: L10n.french, localize: "fr", isSelected: false)
//        let item05 = LangItem(title: "Italiano", subTitle: L10n.italian, localize: "it", isSelected: false)
//        let item06 = LangItem(title: "Bahasa Indonesia", subTitle: L10n.indonesian, localize: "id", isSelected: false)
//        let item07 = LangItem(title: "日本語", subTitle: L10n.japanese, localize: "ja", isSelected: false)
//        let item08 = LangItem(title: "العربية", subTitle: L10n.arabic, localize: "ar", isSelected: false)
//        let item09 = LangItem(title: "简体中文", subTitle: L10n.simplified, localize: "zh-Hans", isSelected: false)
//        let item10 = LangItem(title: "繁体中文", subTitle: L10n.traditional, localize: "zh-Hant", isSelected: false)
//        sectionList = [item00,item01,item02,item03,item04,item05,item06,item07,item08,item09,item10]
        itemList = [item00,item01]
        itemList = itemList.map { item in
            var mutableItem = item
            mutableItem.isSelected = (item.localize == language)
            return mutableItem
        }
    }
}


// MARK: -  =======================PopTopViewDelegate========================
extension CenterLanguagePopVC:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
}

//MARK: ----------TableViewDelegateDataSource-----------
extension CenterLanguagePopVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemList[indexPath.row]
        let cell = tableView.dequeueCell(SetLangPopCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.configure(with: item)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for i in 0..<itemList.count {
            itemList[i].isSelected = false
        }
        itemList[indexPath.row].isSelected = true
        selecedRow = indexPath.row
        let selectedItem = itemList[selecedRow]
        Localize.setCurrentLanguage(selectedItem.localize)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueHeaderFooter(SuperTableViewHeaderFooterView.self)
        return head
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let foot = tableView.dequeueHeaderFooter(SuperTableViewHeaderFooterView.self)
        return foot
    }
}

class SetLangPopCell: SuperTableViewCell {
    private lazy var titleLab = UILabel().hnFont(size: 14.h, weight: .medium).color(kkColorFromHex(kkMainTextColor))
    private lazy var subTitleLab = UILabel().hnFont(size: 12.h, weight: .regular).color(kkColorFromHex("A4A9B1"))
    private lazy var rightImg = UIImageView().image(Asset.addNoteUnCheck.image)
    private lazy var line = UIView().backgroundColor(kkColorFromHex("E8EBF0"))

    override func setUpUI() {
        contentView.addChildView([line,titleLab,subTitleLab, rightImg])
        rightImg.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20.h)
            make.right.equalToSuperview().offset(-20.w)
        }
        titleLab.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(13.h)
            make.left.equalToSuperview().offset(20.w)
            make.right.equalTo(rightImg.snp.left).offset(-10.w)
            make.height.equalTo(17.h)
        }
        subTitleLab.snp.makeConstraints { make in
            make.left.right.equalTo(titleLab)
            make.height.equalTo(15.h)
            make.top.equalTo(titleLab.snp.bottom).offset(3.h)
        }
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
    
    func configure(with item: LangItem) {
        titleLab.text = item.title
        subTitleLab.text = item.subTitle
        if item.isSelected {
            rightImg.image(Asset.addNoteCheck.image)
            titleLab.color(kkColorFromHex(kkMainColor))
        }else{
            rightImg.image(Asset.addNoteUnCheck.image)
            titleLab.color(kkColorFromHex(kkMainTextColor))
        }
    }
}
