//
//  HomePopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/13.
//

import UIKit


class HomeAllNotePopVC: SuperViewController {

    var dismissAction: (() -> Void)?
    private var selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    private lazy var itemList:[FolderItem] = []
    private lazy var recordingItem:RecordingItem? = nil
    private lazy var barView = PopTopView()
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(FloderItemCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(84.h).showsH(false).showsV(false)
    }()
    private lazy var emptyView = SectionEmptyView().hidden(true)
    
    private lazy var bottomV = UIView().backgroundColor(.white).cornerRadius(26.h, corners: [.topLeft,.topRight])
    private lazy var dashBgV = DashedBorderView(cornerRadius: 14.h,lineWidth: 1,lineDashPattern: [4,2],strokeColor: kkColorFromHex(kkMainTextColor)).backgroundColor(.white).onTap {
        let content = HomeAddFloderPopVC()
        content.delegate = self
        let popup = PopupContainerViewController(contentVC: content, height: 259.h)
        content.dismissAction = {
            popup.dismissSelf()
        }
        UIApplication.topViewController()?.present(popup, animated: false)
    }
    private lazy var iconImageV = UIImageView().image(Asset.floder.image).enable(true)
    private lazy var moreImageV = UIImageView().image(Asset.addFloders.image).enable(true)
    private lazy var titleL = UILabel().text(L10n.newFolder).color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)

    init(recordingItem:RecordingItem) {
        super.init(nibName: nil, bundle: nil)
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
        view.addChildView([barView,tableView,emptyView])
        view.addSubview(bottomV)
        barView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(80.h)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(barView.snp.bottom)
            make.bottom.equalToSuperview().offset(-140.h)
        }
        
        emptyView.snp.makeConstraints { make in
            make.width.equalTo(150.h)
            make.height.equalTo(165.h)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50.h)
        }
        
        bottomV.addSubview(dashBgV)
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
        barView.delegate = self
        
        let listData = try! FolderItemStore.shared.fetchAllFolderItem()
        itemList = listData
        guard let targetId = recordingItem?.recordFolderId else { return }
        if let index = itemList.firstIndex(where: { $0.recordFolderId == targetId }) {
            selectedIndexPath = IndexPath(row: index, section: 0)
        } else {
            selectedIndexPath = IndexPath(row: 0, section: 0)
        }
        
        tableView.reloadData()
        
        emptyView.refreshData(emptyImage: Asset.sectionEmpty.image, emptyStr: L10n.allResultsAreNegative)
        if itemList.count == 0 {
            tableView.hidden(true)
            emptyView.hidden(false)
        }else{
            tableView.hidden(false)
            emptyView.hidden(true)
        }
        
    }

}


// MARK: -  =======================HomeAddFloderPopVCDelegate========================
extension HomeAllNotePopVC:HomeAddFloderPopVCDelegate {
    func addFloderSave(Floder:String) {
        let item00 = FolderItemRequest(folderName: Floder, recordFolderId: UUID().uuidString, createTime: Int64(Date().timeIntervalSince1970))
        do{
            try! FolderItemStore.shared.addFolderItem(item00)
        }
        getData()
    }
}

// MARK: -  =======================PopTopViewDelegate========================
extension HomeAllNotePopVC:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
    func refreshSearchDataPop(updatedText: String){
        let listData = try! FolderItemStore.shared.searchByKeyword(updatedText)
        itemList = listData
        tableView.reloadData()
    }
    
    func refreshSearchNoDataPop(){
        let listData = try! FolderItemStore.shared.fetchAllFolderItem()
        itemList = listData
        tableView.reloadData()
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
        let isSelected = indexPath == selectedIndexPath
        let isLast = indexPath.row == itemList.count - 1
        cell.configure(with: itemList[indexPath.row],isLast: isLast,indexPath:indexPath,isSelected: isSelected,isAllNote: true)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previous = selectedIndexPath
        selectedIndexPath = indexPath
        var reloads = [indexPath]
        if previous != indexPath {
            reloads.append(previous)
        }
        tableView.reloadRows(at: reloads, with: .none)
        
        let model = itemList[indexPath.row]
        recordingItem?.recordFolder = model.folderName
        recordingItem?.recordFolderId = model.recordFolderId
        try! RecordingItemStore.shared.updateRecordingItem(recordingItem!)
        
        dismissAction?()
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
    
    func configure(with item: FolderItem,isLast:Bool,indexPath:IndexPath,isSelected: Bool,isAllNote:Bool = false) {
        if indexPath.row == 0 && isAllNote == true {
            bgView.backgroundColor(kkColorFromHex("DEEAFF"))
            titleL.text(item.folderName)
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
            titleL.text(item.folderName)
            iconImageV.image(Asset.floder.image)
            noteNumberL.hidden(false)
            moreImageV.hidden(false)
            let fileCount = RecordingItemStore.shared.fileCount(in: item.recordFolderId!)
            noteNumberL.text("\(fileCount)" + " " + L10n.notes)
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
