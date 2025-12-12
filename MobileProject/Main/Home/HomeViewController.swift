//
//  HomeViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/11.
//

import UIKit

struct RecordItemModel {
    let noteName: String
    let noteType: Int
    let updateTime: Int64
    let isFavorite: Bool
}

class HomeViewController: SuperViewController {

    private lazy var topview = TopView()
    private lazy var tabView = TabView()
    private lazy var itemList:[RecordItemModel] = []
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(RecordItemCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(84.h).showsH(false)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = kkColorFromHex(kkHomeBgColor)
        // Do any additional setup after loading the view.
    }
    
    override func setUpUI() {
        view.addChildView([topview,tabView,tableView])
        topview.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(142.h)
        }
        
        tabView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topview.snp.bottom).offset(18.h)
            make.height.equalTo(40.h)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tabView.snp.bottom).offset(20.h)
            make.bottom.equalToSuperview().offset(-kkTAB_BAR_TOTAL_HEIGHT - 30.h)
        }
        
    }
    override func getData() {
        
        let model00 = RecordItemModel(noteName: "noteName00", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)
        let model01 = RecordItemModel(noteName: "noteName11", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: true)
        let model02 = RecordItemModel(noteName: "noteName22", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)
        let model03 = RecordItemModel(noteName: "noteName33", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)

        itemList = [model00,model01,model02,model03]
        tableView.reloadData()
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}


//MARK: ----------TableViewDelegateDataSource-----------
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(RecordItemCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.configure(with: itemList[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemList[indexPath.row]
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

class RecordItemCell: SuperTableViewCell {
    private lazy var bgView = UIView().backgroundColor(.white).cornerRadius(14.w)
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var moreImageV = UIImageView().image(Asset.moreRight.image).enable(true)
    private lazy var favoriteImageV = UIImageView().image(Asset.homeFavorite.image).enable(true)
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)
    private lazy var typeImageV = UIImageView().image(Asset.homeType00.image)
    private lazy var dateL = UILabel().text("Apr 10,2025   11:30 am").hnFont(size: 12.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor))
    override func setUpUI() {
        self.backgroundColor(.clear)
        contentView.addChildView([bgView,favoriteImageV])
        contentView.backgroundColor(.clear)
        bgView.addChildView([iconImageV,moreImageV,titleL,typeImageV,dateL])
        
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
    
    func configure(with item: RecordItemModel) {
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

