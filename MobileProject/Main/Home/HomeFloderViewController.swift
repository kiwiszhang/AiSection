//
//  HomeViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/11.
//

import UIKit

class HomeFloderViewController: SuperViewController {
    private lazy var itemList:[RecordingItem] = []
    var model:FolderItem? = nil
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(RecordItemCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(84.h).showsH(false)
    }()
    private lazy var emptyAddView = SectionEmptyAddView().hidden(true)

    private lazy var navTopView = NavTopView()
    
    init(model:FolderItem) {
        super.init(nibName: nil, bundle: nil)
        self.model = model
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        itemList = try! RecordingItemStore.shared.fetchByFolderId(model!.recordFolderId!)
        emptyAddView.refreshData(emptyImage: Asset.sectionEmptyAdd.image, emptyStr: L10n.noItemsSavedYet)
        emptyAddView.delegate = self
        navTopView.delegate = self
        navTopView.updateData(title: L10n.searchNotes)
        
        if let data = model {
            navTopView.updateTitle(title: data.folderName!)
            navTopView.updateData(title: L10n.searchFolders)
        }
        
        listDataIsEmpty()
    }
    
    func listDataIsEmpty() {
        tableView.reloadData()
        if itemList.count == 0{
            tableView.hidden(true)
            emptyAddView.hidden(false)
        }else{
            tableView.hidden(false)
            emptyAddView.hidden(true)
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
        let listData = try! RecordingItemStore.shared.searchByKeyword(updatedText)
        itemList = listData
        listDataIsEmpty()
    }
    func refreshSearchNoData(){
        MyLog("refreshSearchNoData")
        let listData = try! RecordingItemStore.shared.fetchByFolderId(model!.recordFolderId!)
        itemList = listData
        listDataIsEmpty()
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
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemList[indexPath.row]
        if UtitilTools.isDemoData(model: item) {
            MyLog("Demo")
        }else{
            let vc = HomeNoteDetailViewController()
            self.navigationController?.pushViewController(vc, animated: true)
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
        let content = HomeAddNotePopViewController(model: model!)
        let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight - 60.h)
        content.dismissAction = { [self] in
            popup.dismissSelf()
            getData()
        }
        UIApplication.topViewController()?.present(popup, animated: false)
    }
}

