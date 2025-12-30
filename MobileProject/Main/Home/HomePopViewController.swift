//
//  HomePopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/13.
//

import UIKit

struct PopItemModel {
    var itemName: String = ""
    var itemIcon: UIImage
}

class HomePopViewController: SuperViewController {

    var dismissAction: (() -> Void)?
    private lazy var itemList:[PopItemModel] = []
    private lazy var recordingItem:RecordingItem? = nil
    private lazy var barView = PopTopView()
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.white).registerCells(PopItemCell.self).scrollEnable(false).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(71.h).showsH(false).showsV(false)
    }()
    
    init(itemList:[PopItemModel],recordingItem:RecordingItem) {
        super.init(nibName: nil, bundle: nil)
        self.itemList = itemList
        self.recordingItem = recordingItem
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor(kkColorFromHex("F0F5FB"))
    }

    override func setUpUI() {
        view.addChildView([barView,tableView])
        barView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(80.h)
        }
        
        tableView.snp.makeConstraints { make in
            make.width.equalTo(335.w)
            make.height.equalTo(355.h)
            make.centerX.equalToSuperview()
            make.top.equalTo(barView.snp.bottom).offset(-13.h)
        }
        tableView.cornerRadius(14.h)
        
    }
    
    override func getData() {
        barView.delegate = self
        barView.addGradientBackground(colors: [kkColorFromHex("F0F5FB"),kkColorFromHex("E6EFFF")], direction: .bottomToTop)
    }

}

// MARK: -  =======================PopTopViewDelegate========================
extension HomePopViewController:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
}

// MARK: -  =======================HomeAddFloderPopVCDelegate========================
extension HomePopViewController:HomeAddFloderPopVCDelegate {
    func addFloderSave(Floder:String) {
        dismissAction?()
        recordingItem?.recordName = Floder
        try! RecordingItemStore.shared.updateRecordingItem(recordingItem!)
        tableView.reloadData()
    }
}


//MARK: ----------TableViewDelegateDataSource-----------
extension HomePopViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(PopItemCell.self, for: indexPath)
        cell.selectionStyle = .none
        let isLast = indexPath.row == itemList.count - 1
        cell.configure(with: itemList[indexPath.row],isLast: isLast)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemList[indexPath.row]
        MyLog(item.itemName)
        if indexPath.row == 0 {
            let content = HomePopViewController(itemList: HomeConfigData.getHomeMoreShareData(), recordingItem: recordingItem!)
            let popup = PopupContainerViewController(contentVC: content, height: 462.h)
            content.dismissAction = {
                popup.dismissSelf()
            }
            UIApplication.topViewController()?.present(popup, animated: false)
        }else if indexPath.row == 1 {
            recordingItem?.isFavorite = !recordingItem!.isFavorite
            try! RecordingItemStore.shared.updateRecordingItem(recordingItem!)
            dismissAction?()
        }else if indexPath.row == 2 {
            let content = HomeNoAllNotePopVC(recordingItem: recordingItem!)
            let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight - 60.h)
            content.dismissAction = {
                popup.dismissSelf()
            }
            UIApplication.topViewController()?.present(popup, animated: false)
        }else if indexPath.row == 3 {
            let content = HomeAddFloderPopVC(topTitle: L10n.rename)
            content.delegate = self
            let popup = PopupContainerViewController(contentVC: content, height: 259.h)
            content.dismissAction = {
                popup.dismissSelf()
            }
            UIApplication.topViewController()?.present(popup, animated: false)
        }else if indexPath.row == 4 {
            try! RecordingItemStore.shared.delete(recordingItem!)
            dismissAction?()
        }
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

class PopItemCell: SuperTableViewCell {
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)
    private lazy var line = UIView().backgroundColor(kkColorFromHex(kkWhiteSliceLineColor))
    override func setUpUI() {
        self.backgroundColor(.clear)
        contentView.addChildView([iconImageV,titleL,line])
        contentView.backgroundColor(.clear)
        iconImageV.snp.makeConstraints { make in
            make.width.height.equalTo(38.h)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16.w)
        }

        titleL.snp.makeConstraints { make in
            make.left.equalTo(iconImageV.snp.right).offset(10.w)
            make.right.equalToSuperview().offset(-10.w)
            make.centerY.equalToSuperview()
            make.height.equalTo(20.h)
        }
        
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview().offset(-1)
        }
    }
    
    func configure(with item: PopItemModel,isLast:Bool) {
        titleL.text(item.itemName)
        iconImageV.image(item.itemIcon)
        line.hidden(isLast)
    }

}
