//
//  HomeViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/11.
//

import UIKit

struct RecordItemModel {
    /// tab第一个和第三个用到的数据
    var noteName: String = ""
    var noteType: Int = 0
    var updateTime: Int64 = 0
    var isFavorite: Bool = false
    
    var isDemo: Bool = false
    var demoSubTitle: String = L10n.discoverAllFeatureswithThisNote
    var demoTry: String = L10n.tryNow
    
    /// 第二个tab用到的数据
    var floderName:String = ""
    var noteNumbers:Int = 0
    var isAddFloder: Bool = false

}

class HomeViewController: SuperViewController {
    private lazy var topview = TopView()
    private lazy var tabView = TabView()
//    private lazy var itemList:[RecordItemModel] = []
    private lazy var itemList:[RecordingItem] = []
    private lazy var itemFolderList:[FolderItem] = []
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(RecordItemCell.self).registerCells(RecordSecendItemCell.self).registerCells(RecordItemDemoCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(84.h).showsH(false).showsV(false)
    }()
    private lazy var emptyView = SectionEmptyView().hidden(true)
    private lazy var emptyAddView = SectionEmptyAddView().hidden(true)
    private lazy var searchText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = kkColorFromHex(kkHomeBgColor)
        // Do any additional setup after loading the view.
        
//        addNoteData()
//        addFolderData()
    }
    
    func addNoteData(){
        let item00 = RecordingItemRequest(updateTime: Int64(Date().timeIntervalSince1970), recordType: 1, recordPath: "234.m4a", recordName: "test-Record-Name567", recordFolder: "Note00", recordFolderId: UUID().uuidString, isFavorite: false, createTime: Int64(Date().timeIntervalSince1970))
        let item01 = RecordingItemRequest(updateTime: Int64(Date().timeIntervalSince1970), recordType: 0, recordPath: "234.m4a", recordName: "test-Record-Name678", recordFolder: "Note01", recordFolderId: UUID().uuidString, isFavorite: true, createTime: Int64(Date().timeIntervalSince1970))
        let item02 = RecordingItemRequest(updateTime: Int64(Date().timeIntervalSince1970), recordType: 1, recordPath: "234.m4a", recordName: "test-Record-Name789", recordFolder: "Note00", recordFolderId: UUID().uuidString, isFavorite: false, createTime: Int64(Date().timeIntervalSince1970))
        let item03 = RecordingItemRequest(updateTime: Int64(Date().timeIntervalSince1970), recordType: 0, recordPath: "234.m4a", recordName: "test-Record-Name890", recordFolder: "Note01", recordFolderId: UUID().uuidString, isFavorite: true, createTime: Int64(Date().timeIntervalSince1970))

        do{
            try! RecordingItemStore.shared.addRecordingItem(item00)
            try! RecordingItemStore.shared.addRecordingItem(item01)
            try! RecordingItemStore.shared.addRecordingItem(item02)
            try! RecordingItemStore.shared.addRecordingItem(item03)
        }
    }
    
    func addFolderData(){
        let item00 = FolderItemRequest(folderName: "Note012", recordFolderId: UUID().uuidString, createTime: Int64(Date().timeIntervalSince1970))
        let item01 = FolderItemRequest(folderName: "Note123", recordFolderId: UUID().uuidString, createTime: Int64(Date().timeIntervalSince1970))
        let item02 = FolderItemRequest(folderName: "Note234", recordFolderId: UUID().uuidString, createTime: Int64(Date().timeIntervalSince1970))
        let item03 = FolderItemRequest(folderName: "Note345", recordFolderId: UUID().uuidString, createTime: Int64(Date().timeIntervalSince1970))

        do{
            try! FolderItemStore.shared.addFolderItem(item00)
            try! FolderItemStore.shared.addFolderItem(item01)
            try! FolderItemStore.shared.addFolderItem(item02)
            try! FolderItemStore.shared.addFolderItem(item03)
        }
    }
    
    
    override func setUpUI() {
        UserDefaultsTools.tabSelected = 0
        view.addChildView([topview,tabView,tableView,emptyView,emptyAddView])
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
            make.bottom.equalToSuperview().offset(-kkTAB_BAR_TOTAL_HEIGHT)
        }
        
        emptyView.snp.makeConstraints { make in
            make.width.equalTo(150.h)
            make.height.equalTo(165.h)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20.h)
        }
        
        emptyAddView.snp.makeConstraints { make in
            make.width.equalTo(150.w)
            make.height.equalTo(254.h)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20.h)
        }
        
        topview.delegate = self
        tabView.delegate = self
        
    }
    override func getData() {
        tabClickItemIndex(0)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        tabClickItemIndex(UserDefaultsTools.tabSelected)
    }
}


// MARK: -  =======================TopViewDelegate========================
extension HomeViewController:TopViewDelegate {
    func refreshSearchData(updatedText: String) {
        MyLog(updatedText)
        searchText = updatedText
        if UserDefaultsTools.tabSelected == 0 {
            let listData = try! RecordingItemStore.shared.searchByKeyword(updatedText)
            itemList = listData
        }
        if UserDefaultsTools.tabSelected == 2 {
            let listData = try! RecordingItemStore.shared.searchByKeyword(updatedText,in: true)
            itemList = listData
        }
        if UserDefaultsTools.tabSelected == 1 {
            let listData = try! FolderItemStore.shared.searchByKeyword(updatedText)
            itemFolderList = listData
        }
        tableView.reloadData()
        listDataisEmpty()
    }
    func refreshSearchNoData(){
        MyLog("refreshSearchNoData")
        searchText = ""
        if UserDefaultsTools.tabSelected == 0 {
            let listData = try! RecordingItemStore.shared.fetchAllRecordingItem()
            itemList = listData
        }
        if UserDefaultsTools.tabSelected == 2 {
            let listData = try! RecordingItemStore.shared.fetchAllRecordingItem(isFavorite: true)
            itemList = listData
        }
        if UserDefaultsTools.tabSelected == 1 {
            let listData = try! FolderItemStore.shared.fetchAllFolderItem()
            itemFolderList = listData
        }
        tableView.reloadData()
        listDataisEmpty()
    }
    func clickVipImage() {
        MyLog("clickVipImage")
    }
}

//MARK: ----------TableViewDelegateDataSource-----------
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
            return itemList.count
        }
        if UserDefaultsTools.tabSelected == 1 {
            return itemFolderList.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
            let model = itemList[indexPath.row]
            if UtitilTools.isDemoData(model: model) {
                let cell = tableView.dequeueCell(RecordItemDemoCell.self, for: indexPath)
                cell.selectionStyle = .none
                cell.configure(with: model)
                return cell
            }
            let cell = tableView.dequeueCell(RecordItemCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configure(with: model)
            return cell
        }
        
        if UserDefaultsTools.tabSelected == 1 {
            let model = itemFolderList[indexPath.row]
            let cell = tableView.dequeueCell(RecordSecendItemCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configure(with: model)
            return cell
        }
        
        let cell = tableView.dequeueCell(RecordItemCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.delegate = self
        cell.configure(with: itemList[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
            let item = itemList[indexPath.row]
            if UtitilTools.isDemoData(model: item) {
                MyLog("Demo")
            }else{
                let vc = HomeNoteDetailViewController(recordingItem: item)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if UserDefaultsTools.tabSelected == 1 {
            let item = itemFolderList[indexPath.row]
            if UtitilTools.isAddFolderData(model: item) {
                let content = HomeAddFloderPopVC()
                content.delegate = self
                let popup = PopupContainerViewController(contentVC: content, height: 259.h)
                content.dismissAction = {
                    popup.dismissSelf()
                }
                UIApplication.topViewController()?.present(popup, animated: false)
            }else{
                UserDefaultsTools.tabSelected = 0
                let vc = HomeFloderViewController(model: item)
                self.navigationController?.pushViewController(vc, animated: true)
            }
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
}


// MARK: -  =======================HomeAddFloderPopVCDelegate========================
extension HomeViewController:HomeAddFloderPopVCDelegate {
    func addFloderSave(Floder:String) {
        let item00 = FolderItemRequest(folderName: Floder, recordFolderId: UUID().uuidString, createTime: Int64(Date().timeIntervalSince1970))
        do{
            try! FolderItemStore.shared.addFolderItem(item00)
        }
    }
}

//MARK: ----------HomeMoveoutPopVCDelegate-----------
extension RecordItemCell: HomeMoveoutPopVCDelegate {
    func updateTableViewData(){
        delegate?.reloadTableData()
    }
}

//MARK: ----------RecordItemCellDelegate-----------
extension HomeViewController: RecordItemCellDelegate {
    func reloadTableData(){
        tabClickItemIndex(UserDefaultsTools.tabSelected)
    }
}

//MARK: ----------RecordSecendItemCellDelegate-----------
extension HomeViewController: RecordSecendItemCellDelegate {
    func reloadSecendTableData(){
        tabClickItemIndex(UserDefaultsTools.tabSelected)
    }
}

@objc protocol RecordItemCellDelegate: AnyObject {
    func reloadTableData()
}

class RecordItemCell: SuperTableViewCell {
    weak var delegate: RecordItemCellDelegate?
    private var itemModel:RecordingItem? = nil
    private var isInFolder:Bool = false
    private lazy var bgView = DashedBorderView(cornerRadius: 14.h,lineWidth: 1,strokeColor: .white).backgroundColor(.white)
    var hitTestInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var moreImageV = UIImageView().image(Asset.moreRight.image).enable(true).onTap { [self] in
        MyLog(itemModel)
        if let model = itemModel {
            if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
                if isInFolder {
                    
                    var itemListData:[PopItemModel] = []
                    if model.isFavorite {
                        itemListData = HomeConfigData.getMoveOutFolderUnFavoriteData()
                    }else{
                        itemListData = HomeConfigData.getMoveOutFolderData()
                    }
                    let content = HomeMoveoutPopVC(itemList: itemListData,recordingItem: itemModel!)
                    content.delegate = self
                    let popup = PopupContainerViewController(contentVC: content, height: 564.h)
                    content.dismissAction = { [self] in
                        popup.dismissSelf()
                        delegate?.reloadTableData()
                    }
                    UIApplication.topViewController()?.present(popup, animated: false)
                }else{
                    var itemListData:[PopItemModel] = []
                    if model.isFavorite {
                        itemListData = HomeConfigData.getHomeMoreUnFavoriteData()
                    }else{
                        itemListData = HomeConfigData.getHomeMoreData()
                    }
                    let content = HomePopViewController(itemList: itemListData,recordingItem: itemModel!)
                    let popup = PopupContainerViewController(contentVC: content, height: 462.h)
                    content.dismissAction = { [self] in
                        popup.dismissSelf()
                        delegate?.reloadTableData()
                    }
                    UIApplication.topViewController()?.present(popup, animated: false)
                }
            }
        }
    }
    private lazy var favoriteImageV = UIImageView().image(Asset.homeFavorite.image).enable(true)
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)
    private lazy var typeImageV = UIImageView().image(Asset.homeType00.image)
    private lazy var dateL = UILabel().text("Apr 10,2025 11:30 am").hnFont(size: 12.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor))
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let largerBounds = bounds.inset(by: hitTestInsets)
        return largerBounds.contains(point)
    }
    
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
    
    func configure(with item: RecordingItem) {
        itemModel = item
        if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
            titleL.text(item.recordName)
            dateL.text(timestampToFormattedString(item.updateTime))
            if item.recordType == 0 {
                typeImageV.image(Asset.homeType00.image)
            }else{
                typeImageV.image(Asset.homeType01.image)
            }
            if item.isFavorite {
                favoriteImageV.hidden(false)
            }else{
                favoriteImageV.hidden(true)
            }
            typeImageV.hidden(false)
            dateL.hidden(false)
            iconImageV.image(Asset.homeNote.image)
        }
    }
    
    func configure(with item: RecordingItem,isInFolder:Bool) {
        itemModel = item
        self.isInFolder = isInFolder
        if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
            titleL.text(item.recordName)
            dateL.text(timestampToFormattedString(item.updateTime))
            if item.recordType == 0 {
                typeImageV.image(Asset.homeType00.image)
            }else{
                typeImageV.image(Asset.homeType01.image)
            }
            if item.isFavorite {
                favoriteImageV.hidden(false)
            }else{
                favoriteImageV.hidden(true)
            }
            typeImageV.hidden(false)
            dateL.hidden(false)
            iconImageV.image(Asset.homeNote.image)
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

@objc protocol RecordSecendItemCellDelegate: AnyObject {
    func reloadSecendTableData()
}
class RecordSecendItemCell: SuperTableViewCell {
    var hitTestInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
    weak var delegate: RecordSecendItemCellDelegate?
    private var itemModel:FolderItem? = nil
    private lazy var bgView = DashedBorderView(cornerRadius: 14.h,lineWidth: 1,strokeColor: .white).backgroundColor(.white)
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var moreImageV = UIImageView().image(Asset.moreRight.image).enable(true).onTap { [self] in
        MyLog(itemModel)
        if let model = itemModel {
            if UserDefaultsTools.tabSelected == 1 {
                var itemListData:[PopItemModel] = HomeConfigData.getHomeFloderData()
                let content = HomeFloderPopViewController(itemList: itemListData,folderItem: model)
                let popup = PopupContainerViewController(contentVC: content, height: 319.h)
                content.dismissAction = { [self] in
                    popup.dismissSelf()
                    delegate?.reloadSecendTableData()
                }
                UIApplication.topViewController()?.present(popup, animated: false)
            }
        }
    }
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)
    private lazy var noteNumberL = UILabel().text("0").hnFont(size: 12.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor))
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let largerBounds = bounds.inset(by: hitTestInsets)
        return largerBounds.contains(point)
    }
    
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
    
    func configure(with item: FolderItem) {
        itemModel = item
        if UserDefaultsTools.tabSelected == 1 {
            iconImageV.image(Asset.floder.image)
            noteNumberL.hidden(false)
            let fileCount = RecordingItemStore.shared.fileCount(in: item.recordFolderId!)
            noteNumberL.text("\(fileCount)" + " " + L10n.notes)
            if UtitilTools.isAddFolderData(model: item) {
                titleL.snp.remakeConstraints { make in
                    make.left.equalTo(iconImageV.snp.right).offset(10.w)
                    make.right.equalTo(moreImageV.snp.left).offset(-8.w)
                    make.centerY.equalToSuperview()
                    make.height.equalTo(17.h)
                }
                moreImageV.snp.remakeConstraints { make in
                    make.width.height.equalTo(28.h)
                    make.centerY.equalToSuperview()
                    make.right.equalToSuperview().offset(-16.w)
                }
                titleL.text(L10n.newFolder)
                noteNumberL.hidden(true)
                moreImageV.image(Asset.addFloders.image)
                bgView.cornerRadius = 14.h
                bgView.lineWidth = 1
                bgView.strokeColor = kkColorFromHex(kkMainTextColor)
                bgView.backgroundColor = kkColorFromHexWithAlpha("FFFFFF", 0.5)
            }else{
                titleL.snp.remakeConstraints { make in
                    make.left.equalTo(iconImageV.snp.right).offset(10.w)
                    make.right.equalTo(moreImageV.snp.left).offset(-8.w)
                    make.top.equalToSuperview().offset(16.h)
                    make.height.equalTo(17.h)
                }
                moreImageV.snp.remakeConstraints { make in
                    make.width.height.equalTo(18.h)
                    make.centerY.equalToSuperview()
                    make.right.equalToSuperview().offset(-16.w)
                }
                titleL.text(item.folderName)
                moreImageV.image(Asset.moreRight.image)
                bgView.cornerRadius = 14.h
                bgView.lineWidth = 1
                bgView.strokeColor = .white
                bgView.backgroundColor = kkColorFromHexWithAlpha("FFFFFF", 1)
            }
        }
    }
}


class RecordItemDemoCell: SuperTableViewCell {
    private lazy var bgView = UIView().backgroundColor(.white).cornerRadius(14.w)
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)
    private lazy var dateL = UILabel().text("Apr 10,2025   11:30 am").hnFont(size: 12.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor))
    private lazy var tryL = UILabel().text(L10n.tryNow).hnFont(size: 10.h, weight: .medium).color(kkColorFromHex(kkMainColor)).cornerRadius(13.h).border(width: 1, color: kkColorFromHex(kkMainColor)).centerAligned()
    override func setUpUI() {
        self.backgroundColor(.clear)
        contentView.addChildView([bgView])
        contentView.backgroundColor(.clear)
        bgView.addChildView([iconImageV,titleL,dateL,tryL])
        
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
        
        tryL.snp.makeConstraints { make in
            make.width.equalTo(60.w)
            make.height.equalTo(26.h)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12.w)
        }
        
        titleL.snp.makeConstraints { make in
            make.left.equalTo(iconImageV.snp.right).offset(10.w)
            make.right.equalTo(tryL.snp.left).offset(-8.w)
            make.top.equalToSuperview().offset(16.h)
            make.height.equalTo(17.h)
        }

        dateL.snp.makeConstraints { make in
            make.left.equalTo(titleL.snp.left)
            make.right.equalTo(tryL.snp.left).offset(-4.w)
            make.top.equalTo(titleL.snp.bottom).offset(4.h)
            make.height.equalTo(15.h)
        }
        
        bgView.addGradientBackground(colors: [kkColorFromHex("D4E4FF"),kkColorFromHex("BAD6FF")], direction: .bottomLeftToTopRight)

    }
    
    func configure(with item: RecordingItem) {
        titleL.text(L10n.welcome)
        dateL.text(L10n.discoverAllFeatureswithThisNote)
        tryL.text(L10n.tryNow)
    }
}



//MARK: ----------TableViewDelegateDataSource-----------
extension HomeViewController:TabViewDelegate {
    func tabClickItemIndex(_ index: Int) {
        topview.updateData(searchText: "")
        UserDefaultsTools.tabSelected = index
        if index == 0 {
            let items = try! RecordingItemStore.shared.fetchAllRecordingItem()
            itemList = items
            emptyView.refreshData(emptyImage: Asset.sectionEmpty.image, emptyStr: L10n.allResultsAreNegative)
        }else if index == 1 {
            let items = try! FolderItemStore.shared.fetchAllFolderItem()
            itemFolderList = items
            emptyView.refreshData(emptyImage: Asset.sectionEmpty.image, emptyStr: L10n.allResultsAreNegative)
        }else if index == 2 {
            let items = try! RecordingItemStore.shared.fetchAllRecordingItem(isFavorite: true)
            itemList = items
            emptyAddView.refreshData(emptyImage: Asset.sectionEmptyAdd.image, emptyStr: L10n.noItemsSavedYet)
            emptyAddView.delegate = self

        }
        tableView.reloadData()
        listDataisEmpty()
    }
    
    func listDataisEmpty(){
        if UserDefaultsTools.tabSelected == 0 {
            if itemList.count == 0{
                tableView.hidden(true)
                emptyAddView.hidden(true)
                emptyView.hidden(false)
            }else{
                tableView.hidden(false)
                emptyView.hidden(true)
                emptyAddView.hidden(true)
            }
        }else if UserDefaultsTools.tabSelected == 1 {
            if itemFolderList.count == 0{
                tableView.hidden(true)
                emptyAddView.hidden(true)
                emptyView.hidden(false)
            }else{
                tableView.hidden(false)
                emptyView.hidden(true)
                emptyAddView.hidden(true)
            }
        }else {
            if itemList.count == 0{
                tableView.hidden(true)
                emptyAddView.hidden(false)
                emptyView.hidden(true)
            }else{
                tableView.hidden(false)
                emptyView.hidden(true)
                emptyAddView.hidden(true)
            }
        }
    }
}

// MARK: -  =====================SectionEmptyAddViewDelegate=========================
extension HomeViewController:SectionEmptyAddViewDelegate {
    func addANoteClick(){
        MyLog("addANoteClick")
        let iLists = try! RecordingItemStore.shared.searchByKeyword(searchText)
        if iLists.isEmpty {
            let content = CenterClickPopViewController()
            let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight,isMiddle: true)
            content.dismissAction = { [self] in
                popup.dismissSelf()
                searchText = ""
            }
            UIApplication.topViewController()?.present(popup, animated: false)
        }else{
            let content = HomeAddNotePopViewController(model: nil,searchText: searchText)
            let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight - 60.h)
            content.dismissAction = { [self] in
                popup.dismissSelf()
                searchText = ""
                tabClickItemIndex(UserDefaultsTools.tabSelected)
            }
            UIApplication.topViewController()?.present(popup, animated: false)
        }
    }
}


