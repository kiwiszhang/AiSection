//
//  HomeFloderPopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/15.
//

import UIKit

class HomeFloderPopViewController: SuperViewController {
    var dismissAction: (() -> Void)?
    private lazy var itemList:[PopItemModel] = []
    private lazy var folderItem:FolderItem? = nil
    private lazy var barView = PopTopView()
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.white).registerCells(PopItemCell.self).scrollEnable(false).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(71.h).showsH(false).showsV(false)
    }()
    
    init(itemList:[PopItemModel],folderItem:FolderItem) {
        super.init(nibName: nil, bundle: nil)
        self.itemList = itemList
        self.folderItem = folderItem
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
            make.height.equalTo((itemList.count * 71).h)
            make.centerX.equalToSuperview()
            make.top.equalTo(barView.snp.bottom).offset(-13.h)
        }
        tableView.cornerRadius(14.h)
        
    }
    
    override func getData() {
        barView.delegate = self
        barView.addGradientBackground(colors: [kkColorFromHex("F0F5FB"),kkColorFromHex("E6EFFF")], direction: .bottomToTop)
        barView.updateData(title: L10n.more)
    }
    

}


// MARK: -  =======================PopTopViewDelegate========================
extension HomeFloderPopViewController:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
}

//MARK: ----------TableViewDelegateDataSource-----------
extension HomeFloderPopViewController: UITableViewDelegate, UITableViewDataSource {
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
            let content = HomeAddNotePopViewController(model: folderItem!)
            let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight - 60.h)
            content.dismissAction = { [self] in
                popup.dismissSelf()
                dismissAction?()
            }
            UIApplication.topViewController()?.present(popup, animated: false)
        }else if indexPath.row == 1 {
            let content = HomeAddFloderPopVC()
            content.delegate = self
            let popup = PopupContainerViewController(contentVC: content, height: 259.h)
            content.dismissAction = {
                popup.dismissSelf()
            }
            UIApplication.topViewController()?.present(popup, animated: false)
        }else if indexPath.row == 2 {
            try! FolderItemStore.shared.delete(folderItem!)
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

// MARK: -  =======================HomeAddFloderPopVCDelegate========================
extension HomeFloderPopViewController:HomeAddFloderPopVCDelegate {
    func addFloderSave(Floder:String) {
        dismissAction?()
        folderItem!.folderName = Floder
        try! FolderItemStore.shared.updateFolderItem(folderItem!)
    }
}
