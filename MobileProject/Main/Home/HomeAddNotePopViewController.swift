//
//  HomeFloderPopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/15.
//

import UIKit

class HomeAddNotePopViewController: SuperViewController {
    var dismissAction: (() -> Void)?
    private var selectedIndex: IndexPath?
    private lazy var itemList:[RecordItemModel] = []
//    itemList:[RecordItemModel]
    private lazy var barView = PopTopView()
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(RecordItemAddNoteCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(84.h).showsH(false).showsV(false)
    }()
    private lazy var bottomV = UIView().backgroundColor(.white).cornerRadius(20.h, corners: [.topLeft,.topRight])
    private lazy var bottomLeft = UILabel().text(L10n.reset).hnFont(size: 18.h, weight: .medium).color(kkColorFromHex(kkMainColor)).centerAligned().cornerRadius(12.h).border(width: 1, color: kkColorFromHex(kkIconColor)).backgroundColor(.white)
    private lazy var bottomRight = UILabel().text(L10n.confirm).hnFont(size: 18.h, weight: .medium).color(.white).centerAligned().cornerRadius(12.h).backgroundColor(kkColorFromHex(kkMainColor))

    
    init(itemList:[RecordItemModel]) {
        super.init(nibName: nil, bundle: nil)
        self.itemList = itemList
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        bottomV.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(110.h)
        }
        
        tableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(barView.snp.bottom).offset(-13.h)
            make.width.equalToSuperview()
            make.bottom.equalTo(bottomV.snp.top).offset(0.h)
        }
        tableView.cornerRadius(14.h)
        
        bottomV.addChildView([bottomLeft,bottomRight])
        bottomLeft.snp.makeConstraints { make in
            make.width.equalTo(160.w)
            make.height.equalTo(50.h)
            make.left.equalToSuperview().offset(20.w)
            make.top.equalToSuperview().offset(19.h)
        }
        
        bottomRight.snp.makeConstraints { make in
            make.width.equalTo(160.w)
            make.height.equalTo(50.h)
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalToSuperview().offset(19.h)
        }
        
    }
    
    override func getData() {
        barView.delegate = self
        barView.addGradientBackground(colors: [kkColorFromHex("F0F5FB"),kkColorFromHex("E6EFFF")], direction: .bottomToTop)
        barView.updateData(title: L10n.addNote,isSearch: true)
        barView.updateSearchData(title: L10n.searchNotes)
    }
    
}


// MARK: -  =======================PopTopViewDelegate========================
extension HomeAddNotePopViewController:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
    
    func clickSearch() {
        MyLog("clickSearch")
    }
}

//MARK: ----------TableViewDelegateDataSource-----------
extension HomeAddNotePopViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(RecordItemAddNoteCell.self, for: indexPath)
        cell.selectionStyle = .none
//        let isLast = indexPath.row == itemList.count - 1
        let isSelected = indexPath == selectedIndex
        cell.configure(with: itemList[indexPath.row],isSelected:isSelected)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previous = selectedIndex
        selectedIndex = indexPath
        var reloads = [indexPath]
        if let previous, previous != indexPath {
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
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//        }
//    }
//    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
//        for cell in tableView.visibleCells {
//        }
//    }
}

class RecordItemAddNoteCell: SuperTableViewCell {
    private var itemModel:RecordItemModel? = nil
    private lazy var bgView = UIView().backgroundColor(.white).cornerRadius(14.w)
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var moreImageV = UIImageView().image(Asset.moreRight.image).enable(true).onTap { [self] in
        MyLog(itemModel)
        if let model = itemModel {
           
        }
    }
    private lazy var favoriteImageV = UIImageView().image(Asset.homeFavorite.image).enable(true)
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)
    private lazy var typeImageV = UIImageView().image(Asset.homeType00.image)
    private lazy var checkImageV = UIImageView().image(Asset.addNoteUnCheck.image)
    private lazy var dateL = UILabel().text("Apr 10,2025 11:30 am").hnFont(size: 12.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor))
    override func setUpUI() {
        self.backgroundColor(.clear)
        contentView.addChildView([bgView,favoriteImageV])
        contentView.backgroundColor(.clear)
        bgView.addChildView([iconImageV,moreImageV,titleL,typeImageV,dateL,checkImageV])
        
        bgView.snp.makeConstraints { make in
            make.width.equalTo(343.w)
            make.height.equalTo(70.h)
            make.center.equalToSuperview()
        }
        
        checkImageV.snp.makeConstraints { make in
            make.width.height.equalTo(20.h)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(14.w)
        }
        
        
        iconImageV.snp.makeConstraints { make in
            make.width.height.equalTo(36.h)
            make.centerY.equalToSuperview()
            make.left.equalTo(checkImageV.snp.right).offset(14.w)
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
        
        typeImageV.snp.makeConstraints { make in
            make.width.height.equalTo(16.h)
            make.left.equalTo(titleL)
            make.top.equalTo(titleL.snp.bottom).offset(4.h)
        }
        
        favoriteImageV.snp.makeConstraints { make in
            make.width.height.equalTo(22.h)
            make.left.equalTo(bgView.snp.left).offset(-4.h)
            make.top.equalTo(bgView.snp.top).offset(-4.h)
        }
        
        dateL.snp.makeConstraints { make in
            make.left.equalTo(typeImageV.snp.right).offset(4.w)
            make.right.equalTo(titleL)
            make.top.equalTo(typeImageV)
            make.height.equalTo(15.h)
        }


    }
    
    func configure(with item: RecordItemModel,isSelected:Bool) {
        itemModel = item
                
        titleL.text(item.noteName)
        dateL.text(timestampToFormattedString(item.updateTime))
        if item.noteType == 0 {
            typeImageV.image(Asset.homeType00.image)
        }else{
            typeImageV.image(Asset.homeType01.image)
        }
        if item.isFavorite {
            favoriteImageV.hidden(false)
        }else{
            favoriteImageV.hidden(true)
        }
        iconImageV.image(Asset.homeNote.image)
        
        if isSelected {
            checkImageV.image(Asset.addNoteCheck.image)
        }else{
            checkImageV.image(Asset.addNoteUnCheck.image)
        }
        
    }
    
    /// 时间戳转：Apr 10,2025 10:30 am这种格式的时间
    public func timestampToFormattedString(_ timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM dd, yyyy  hh:mm a"   // Apr 10, 2025  10:30 AM
        return formatter.string(from: date).lowercased() // am/pm 变为小写
    }
}
