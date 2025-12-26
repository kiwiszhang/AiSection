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
    private lazy var itemList:[RecordItemModel] = []
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).registerCells(RecordItemCell.self).registerCells(RecordSecendItemCell.self).registerCells(RecordItemDemoCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(84.h).showsH(false)
    }()
    private lazy var emptyView = SectionEmptyView().hidden(true)
    private lazy var emptyAddView = SectionEmptyAddView().hidden(true)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = kkColorFromHex(kkHomeBgColor)
        // Do any additional setup after loading the view.
        
        let client = ByteDanceOpenSpeechClient(
            config: .init(
                appKey: XApiAppKey,
                accessKey: XApiAccessKey,
                resourceId: XApiResourceId
            )
        )
        Task {
            do {
                let taskID = try await client.submitOfflineAudio(
                    fileURL: "https://aisection.tos-cn-beijing.volces.com/Recording/123.m4a"
                )
                MyLog("✅ TaskID:\(taskID)")
                
                let finished = try await client.waitUntilFinished(taskID: taskID)
                MyLog("📌 finished:\(finished)")
                if let url = finished.Result?.AudioTranscriptionFile {
                    let listData = try await client.fetchAudioTranscription(from: url)
                    listData.forEach { item in
                        MyLog("🧑 Speaker: \(item.speaker.name ?? "Speaker")")
                        MyLog("content: \(item.content)")
                    }
                }
                
                if let url = finished.Result?.ChapterFile {
                    let listData = try await client.fetchChapterFile(from: url)
                    MyLog(listData.chapterSummary)
                }
                
                if let url = finished.Result?.InformationExtractionFile {
                    let listData = try await client.fetchInformationExtractionFile(from: url)
                    MyLog(listData.todoList)
                }
                
                if let url = finished.Result?.SummarizationFile {
                    let itemData = try await client.fetchSummarizationFile(from: url)
                    MyLog(itemData.title)
                    MyLog(itemData.paragraph)
                }
                
                if let url = finished.Result?.TranslationFile {
                    let listData = try await client.fetchTranslationFile(from: url)
                    MyLog(listData)
                }
                
            } catch {
                MyLog("❌ Error: \(error.localizedDescription)")
            }
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
    }
}


// MARK: -  =======================TopViewDelegate========================
extension HomeViewController:TopViewDelegate {
    func refreshSearchData(updatedText: String) {
        MyLog(updatedText)
    }
    func refreshSearchNoData(){
        MyLog("refreshSearchNoData")
    }
    func clickVipImage() {
        MyLog("clickVipImage")
    }
}

//MARK: ----------TableViewDelegateDataSource-----------
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = itemList[indexPath.row]
        
        if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
            if model.isDemo {
                let cell = tableView.dequeueCell(RecordItemDemoCell.self, for: indexPath)
                cell.selectionStyle = .none
                cell.configure(with: itemList[indexPath.row])
                return cell
            }
            let cell = tableView.dequeueCell(RecordItemCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.configure(with: itemList[indexPath.row])
            return cell
        }
        
        if UserDefaultsTools.tabSelected == 1 {
            let cell = tableView.dequeueCell(RecordSecendItemCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.configure(with: itemList[indexPath.row])
            return cell
        }
        
        let cell = tableView.dequeueCell(RecordItemCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.configure(with: itemList[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemList[indexPath.row]
        
        if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
            if item.isDemo {
                MyLog("Demo")
            }else{
                let vc = HomeNoteDetailViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if UserDefaultsTools.tabSelected == 1 {
            if item.isAddFloder {
                let content = HomeAddFloderPopVC()
                let popup = PopupContainerViewController(contentVC: content, height: 259.h)
                content.dismissAction = {
                    popup.dismissSelf()
                }
                UIApplication.topViewController()?.present(popup, animated: false)
            }else{
                UserDefaultsTools.tabSelected = 0
                let vc = HomeFloderViewController()
                vc.model = item
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

class RecordItemCell: SuperTableViewCell {
    private var itemModel:RecordItemModel? = nil
    private lazy var bgView = DashedBorderView(cornerRadius: 14.h,lineWidth: 1,strokeColor: .white).backgroundColor(.white)
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var moreImageV = UIImageView().image(Asset.moreRight.image).enable(true).onTap { [self] in
        MyLog(itemModel)
        if let model = itemModel {
            if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
                var itemListData:[PopItemModel] = []
                if model.isFavorite {
                    itemListData = HomeConfigData.getHomeMoreUnFavoriteData()
                }else{
                    itemListData = HomeConfigData.getHomeMoreData()
                }
                let content = HomePopViewController(itemList: itemListData)
                let popup = PopupContainerViewController(contentVC: content, height: 462.h)
                content.dismissAction = {
                    popup.dismissSelf()
                }
                UIApplication.topViewController()?.present(popup, animated: false)
            }
        }
    }
    private lazy var favoriteImageV = UIImageView().image(Asset.homeFavorite.image).enable(true)
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .medium)
    private lazy var typeImageV = UIImageView().image(Asset.homeType00.image)
    private lazy var dateL = UILabel().text("Apr 10,2025 11:30 am").hnFont(size: 12.h, weight: .regular).color(kkColorFromHex(kkSubTitleColor))
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
        itemModel = item
        if UserDefaultsTools.tabSelected == 0 || UserDefaultsTools.tabSelected == 2 {
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

class RecordSecendItemCell: SuperTableViewCell {
    private var itemModel:RecordItemModel? = nil
    private lazy var bgView = DashedBorderView(cornerRadius: 14.h,lineWidth: 1,strokeColor: .white).backgroundColor(.white)
    private lazy var iconImageV = UIImageView().image(Asset.homeNote.image).enable(true)
    private lazy var moreImageV = UIImageView().image(Asset.moreRight.image).enable(true).onTap { [self] in
        MyLog(itemModel)
        if let model = itemModel {
            if UserDefaultsTools.tabSelected == 1 {
                var itemListData:[PopItemModel] = HomeConfigData.getHomeFloderData()
                let content = HomeFloderPopViewController(itemList: itemListData)
                let popup = PopupContainerViewController(contentVC: content, height: 319.h)
                content.dismissAction = {
                    popup.dismissSelf()
                }
                UIApplication.topViewController()?.present(popup, animated: false)
            }
        }
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
    
    func configure(with item: RecordItemModel) {
        itemModel = item
        if UserDefaultsTools.tabSelected == 1 {
            titleL.text(item.floderName)
            iconImageV.image(Asset.floder.image)
            noteNumberL.hidden(false)
            noteNumberL.text("\(item.noteNumbers)" + " " + L10n.notes)
            if item.isAddFloder {
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
    
    func configure(with item: RecordItemModel) {
        titleL.text(item.noteName)
        dateL.text(item.demoSubTitle)
        tryL.text(item.demoTry)
    }
}



//MARK: ----------TableViewDelegateDataSource-----------
extension HomeViewController:TabViewDelegate {
    func tabClickItemIndex(_ index: Int) {
        UserDefaultsTools.tabSelected = index
        let model00 = RecordItemModel(noteName: "Meeting minutes", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)
        let model01 = RecordItemModel(noteName: "Meeting Notice", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: true)
        let model02 = RecordItemModel(noteName: "Work Summary", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)
        let model03 = RecordItemModel(noteName: "Annual Meeting Arrangements", noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false)
        let model = RecordItemModel(noteName: L10n.welcome, noteType: 0, updateTime: Int64(Date().timeIntervalSince1970), isFavorite: false,isDemo: true)

        
        let model10 = RecordItemModel(floderName: "On business trip",noteNumbers: 123)
        let model11 = RecordItemModel(floderName: "Annual meeting",noteNumbers: 2)
        let model12 = RecordItemModel(floderName: "Equipment inspection",noteNumbers: 4562)
        let model13 = RecordItemModel(floderName: "Office Notes",noteNumbers: 3)
        let model14 = RecordItemModel(floderName: L10n.newFolder,noteNumbers: 3,isAddFloder:true)
        
        if index == 0 {
            itemList = [model00,model01,model02,model03,model]
//            itemList = []
            emptyView.refreshData(emptyImage: Asset.sectionEmpty.image, emptyStr: L10n.allResultsAreNegative)
        }else if index == 1 {
            itemList = [model10,model11,model12,model13,model14]
//            itemList = []
            emptyAddView.refreshData(emptyImage: Asset.sectionEmptyAdd.image, emptyStr: L10n.noItemsSavedYet)
            emptyAddView.delegate = self
        }else {
            itemList = [model]
//            itemList = []
            emptyView.refreshData(emptyImage: Asset.sectionEmpty.image, emptyStr: L10n.allResultsAreNegative)
        }
        tableView.reloadData()
        
        if itemList.count == 0{
            tableView.hidden(true)
            if index == 1 {
                emptyAddView.hidden(false)
                emptyView.hidden(true)
            }else{
                emptyAddView.hidden(true)
                emptyView.hidden(false)
            }
        }else{
            tableView.hidden(false)
            emptyView.hidden(true)
            emptyAddView.hidden(true)
        }
    }
}

// MARK: -  =====================SectionEmptyAddViewDelegate=========================
extension HomeViewController:SectionEmptyAddViewDelegate {
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
        
//        let content = CenterClickPopViewController()
//        let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight,isMiddle: true)
//        content.dismissAction = {
//            popup.dismissSelf()
//        }
//        UIApplication.topViewController()?.present(popup, animated: false)
    }
}


