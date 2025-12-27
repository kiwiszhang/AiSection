//
//  HomeViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/11.
//

import UIKit

class HomeFloderViewController: SuperViewController {
    private lazy var itemList:[RecordItemModel] = []
    var model:RecordItemModel? = nil
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(RecordItemCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(84.h).showsH(false)
    }()
    private lazy var emptyAddView = SectionEmptyAddView().hidden(true)

    private lazy var navTopView = NavTopView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = kkColorFromHex(kkHomeBgColor)
        // Do any additional setup after loading the view.
    }
    
    override func setUpUI() {
        view.addChildView([navTopView,tableView,emptyAddView])
        navTopView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(140.h)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(navTopView.snp.bottom).offset(8.h)
            make.bottom.equalToSuperview().offset(-kkTAB_BAR_TOTAL_HEIGHT)
        }
        emptyAddView.snp.makeConstraints { make in
            make.width.equalTo(150.w)
            make.height.equalTo(254.h)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20.h)
        }
    }
    override func getData() {

        let model00 = RecordItemModel(noteName: "Meeting minutes", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)
        let model01 = RecordItemModel(noteName: "Meeting Notice", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: true)
        let model02 = RecordItemModel(noteName: "Work Summary", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)
        let model03 = RecordItemModel(noteName: "Annual Meeting Arrangements", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)
        
        itemList = [model00,model01,model02,model03]
        itemList = []

        emptyAddView.refreshData(emptyImage: Asset.sectionEmptyAdd.image, emptyStr: L10n.noItemsSavedYet)
        emptyAddView.delegate = self
        
        tableView.reloadData()
        
        if itemList.count == 0{
            tableView.hidden(true)
            emptyAddView.hidden(false)
        }else{
            tableView.hidden(false)
            emptyAddView.hidden(true)
        }
        navTopView.delegate = self
        
        if let data = model {
            navTopView.updateTitle(title: data.floderName)
            navTopView.updateData(title: L10n.searchFolders)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaultsTools.tabSelected = 1
    }

}

// MARK: -  =======================NavTopViewDelegate========================
extension HomeFloderViewController:NavTopViewDelegate {
    func backClick(){
        self.navigationController?.popViewController(animated: true)
    }
    func moreClick(){
        MyLog("moreClick")
    }
    func refreshSearchData(updatedText: String) {
        MyLog(updatedText)
    }
    func refreshSearchNoData(){
        MyLog("refreshSearchNoData")
    }
}


//MARK: ----------TableViewDelegateDataSource-----------
extension HomeFloderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = itemList[indexPath.row]
        let cell = tableView.dequeueCell(RecordItemCell.self, for: indexPath)
        cell.selectionStyle = .none
//        cell.configure(with: itemList[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemList[indexPath.row]
        if item.isDemo {
            MyLog("Demo")
        }else{
            MyLog("Other")
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

// MARK: -  =====================SectionEmptyAddViewDelegate=========================
extension HomeFloderViewController:SectionEmptyAddViewDelegate {
    func addANoteClick(){
        MyLog("addANoteClick")
        let model00 = RecordItemModel(noteName: "Meeting minutes", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)
        let model01 = RecordItemModel(noteName: "Meeting Notice", noteType: 1, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: true)
        let model02 = RecordItemModel(noteName: "Work Summary", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)
        let model03 = RecordItemModel(noteName: "Annual Meeting Arrangements", noteType: 1, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)

        let model04 = RecordItemModel(noteName: "Meeting minutes", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)
        let model05 = RecordItemModel(noteName: "Meeting Notice", noteType: 1, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: true)
        let model06 = RecordItemModel(noteName: "Work Summary", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)
        let model07 = RecordItemModel(noteName: "Annual Meeting Arrangements", noteType: 1, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)

        
        let content = HomeAddNotePopViewController(itemList: [model00,model01,model02,model03,model04,model05,model06,model07,model00,model01])
        let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight - 60.h)
        content.dismissAction = {
            popup.dismissSelf()
        }
        UIApplication.topViewController()?.present(popup, animated: false)
    }
}

