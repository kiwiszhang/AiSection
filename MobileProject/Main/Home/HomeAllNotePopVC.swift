//
//  HomePopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/13.
//

import UIKit


class HomeAllNotePopVC: SuperViewController {

    var dismissAction: (() -> Void)?
    private var selectedIndex: IndexPath = IndexPath(row: 0, section: 0)
    private lazy var itemList:[RecordItemModel] = []
    private lazy var barView = PopTopView()
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(FloderItemCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(84.h).showsH(false).showsV(false)
    }()
    
    private lazy var bottomV = UIView().backgroundColor(.white).cornerRadius(26.h, corners: [.topLeft,.topRight])
    private lazy var dashBgV = UIView().backgroundColor(.white).cornerRadius(14.h)
    private lazy var iconImageV = UIImageView().image(Asset.floder.image).enable(true)
    private lazy var moreImageV = UIImageView().image(Asset.addFloders.image).enable(true)
    private lazy var titleL = UILabel().text(L10n.newFolder).color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor(kkColorFromHex("F0F5FB"))
    }

    override func setUpUI() {
        view.addChildView([barView,tableView,bottomV])
        barView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(80.h)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(barView.snp.bottom)
            make.bottom.equalToSuperview().offset(-140.h)
        }
        
        bottomV.addChildView([dashBgV])
        bottomV.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(120.h)
        }
        
        dashBgV.addChildView([iconImageV,moreImageV,titleL])
        dashBgV.snp.makeConstraints { make in
            make.width.equalTo(343.w)
            make.height.equalTo(70.h)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(18.h)
        }
        
        iconImageV.snp.makeConstraints { make in
            make.width.height.equalTo(36.h)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16.w)
        }
        
        moreImageV.snp.makeConstraints { make in
            make.width.height.equalTo(28.h)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16.w)
        }
        
        titleL.snp.makeConstraints { make in
            make.left.equalTo(iconImageV.snp.right).offset(10.w)
            make.right.equalTo(moreImageV.snp.left).offset(-8.w)
            make.centerY.equalToSuperview()
            make.height.equalTo(17.h)
        }
        
        
        
    }
    
    override func getData() {
        barView.delegate = self
        barView.addGradientBackground(colors: [kkColorFromHex("F0F5FB"),kkColorFromHex("E6EFFF")], direction: .bottomToTop)
        barView.updateData(title: L10n.folder,isSearch: true)
        barView.updateSearchData(title: L10n.searchFolders)
        
        let model00 = RecordItemModel(floderName: L10n.allNotes,noteNumbers: 0)
        let model10 = RecordItemModel(floderName: "On business trip",noteNumbers: 123)
        let model11 = RecordItemModel(floderName: "Annual meeting",noteNumbers: 2)
        let model12 = RecordItemModel(floderName: "Equipment inspection",noteNumbers: 4562)
        let model13 = RecordItemModel(floderName: "Office Notes",noteNumbers: 3)
        let model14 = RecordItemModel(floderName: L10n.newFolder,noteNumbers: 3,isAddFloder:true)
        
        itemList = [model00,model10,model11,model12,model13,model14,model10,model11,model12,model13,model10,model11,model12,model13]
        tableView.reloadData()
        
        
    }

}

// MARK: -  =======================PopTopViewDelegate========================
extension HomeAllNotePopVC:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
}

//MARK: ----------TableViewDelegateDataSource-----------
extension HomeAllNotePopVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(FloderItemCell.self, for: indexPath)
        cell.selectionStyle = .none
        let isSelected = indexPath == selectedIndex
        let isLast = indexPath.row == itemList.count - 1
        cell.configure(with: itemList[indexPath.row],isLast: isLast,indexPath:indexPath,isSelected: isSelected)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previous = selectedIndex
        selectedIndex = indexPath
        var reloads = [indexPath]
        if previous != indexPath {
            reloads.append(previous)
        }
        tableView.reloadRows(at: reloads, with: .none)
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

class FloderItemCell: SuperTableViewCell {
    private lazy var bgView = UIView().backgroundColor(.white).cornerRadius(14.w)
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var moreImageV = UIImageView().image(Asset.moreRight.image).enable(true).onTap { [self] in
    }
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)
    private lazy var noteNumberL = UILabel().text("0").hnFont(size: 12.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor))
    override func setUpUI() {
        self.backgroundColor(.clear)
        contentView.addChildView([bgView])
        contentView.backgroundColor(.clear)
        bgView.addChildView([iconImageV,moreImageV,titleL,noteNumberL])
        
        bgView.snp.makeConstraints { make in
            make.width.equalTo(343.w)
            make.height.equalTo(70.h)
            make.center.equalToSuperview()
        }
        
        iconImageV.snp.makeConstraints { make in
            make.width.height.equalTo(36.h)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16.w)
        }
        
        moreImageV.snp.makeConstraints { make in
            make.width.height.equalTo(18.h)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16.w)
        }
        
        titleL.snp.makeConstraints { make in
            make.left.equalTo(iconImageV.snp.right).offset(10.w)
            make.right.equalTo(moreImageV.snp.left).offset(-8.w)
            make.top.equalToSuperview().offset(16.h)
            make.height.equalTo(17.h)
        }
        
        noteNumberL.snp.makeConstraints { make in
            make.left.equalTo(titleL.snp.left).offset(0.w)
            make.right.equalTo(titleL)
            make.top.equalTo(titleL.snp.bottom).offset(5.h)
            make.height.equalTo(15.h)
        }

    }
    
    func configure(with item: RecordItemModel,isLast:Bool,indexPath:IndexPath,isSelected: Bool) {
        if indexPath.row == 0 {
            bgView.backgroundColor(kkColorFromHex("DEEAFF"))
            titleL.text(item.floderName)
            iconImageV.image(Asset.allNote.image)
            noteNumberL.hidden(true)
            moreImageV.hidden(true)
            titleL.snp.remakeConstraints { make in
                make.left.equalTo(iconImageV.snp.right).offset(10.w)
                make.right.equalTo(moreImageV.snp.left).offset(-8.w)
                make.centerY.equalTo(iconImageV)
                make.height.equalTo(17.h)
            }
        }else{
            bgView.backgroundColor(kkColorFromHex("FFFFFF"))
            titleL.text(item.floderName)
            iconImageV.image(Asset.floder.image)
            noteNumberL.hidden(false)
            moreImageV.hidden(false)
            noteNumberL.text("\(item.noteNumbers)" + " " + L10n.notes)
            titleL.snp.remakeConstraints { make in
                make.left.equalTo(iconImageV.snp.right).offset(10.w)
                make.right.equalTo(moreImageV.snp.left).offset(-8.w)
                make.top.equalToSuperview().offset(16.h)
                make.height.equalTo(17.h)
            }
        }
        
        if isSelected {
            bgView.border(width: 1, color: kkColorFromHex(kkMainColor))
        }else{
            bgView.border(width: 0, color: .clear)
        }
    }
}
