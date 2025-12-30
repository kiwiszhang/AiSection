//
//  HomeViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/11.
//

import UIKit

struct DetailNoteItemModel {
    var noteName: String = ""
    var noteDetail: String = ""
}

class HomeNoteDetailViewController: SuperViewController {
    private lazy var itemList:[DetailNoteItemModel] = []
    var model:DetailNoteItemModel? = nil
    private lazy var recordingItem:RecordingItem? = nil
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.white).registerCells(DetailNoteItemCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeight(184.h).showsH(false).showsV(false)
    }()
    private lazy var navTopView = DetailNavTopView()
    private lazy var bottomView = DetailBottomView().cornerRadius(16.h, corners: [.topLeft,.topRight])
    private lazy var tableHeaderView = DetailTableHeaderView().backgroundColor(.white)
    private lazy var segmentV = DetailSegmentView().hidden(true)

    private let showThreshold: CGFloat = 162.h + 4.h
    private var isControlVisible = false

    init(recordingItem:RecordingItem) {
        super.init(nibName: nil, bundle: nil)
        self.recordingItem = recordingItem
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        UserDefaultsTools.segmentIndex = 0
    }
    
    override func setUpUI() {
        view.addChildView([navTopView,bottomView,tableView,segmentV])
        navTopView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(88.h)
        }
        
        segmentV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(navTopView.snp.bottom)
            make.height.equalTo(56.h)
        }
        segmentV.delegate = self
        
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(110.h)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(navTopView.snp.bottom)
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        navTopView.delegate = self
        bottomView.delegate = self
        
        tableHeaderView.frame = CGRect(x: 0, y: 0,
                                       width: kkScreenWidth,
                                       height: 226.h)
        tableView.tableHeaderView = tableHeaderView
        tableHeaderView.delegate = self
        segmentV.segmentedView.setSelectedIndex(UserDefaultsTools.segmentIndex, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    
    override func getData() {

        let model00 = DetailNoteItemModel(noteName: "Action Item",noteDetail: "The content is displayed here.The content is displayed here.The content is displayed here.The content is displayed here.The content is displayed here.")

        let model01 = DetailNoteItemModel(noteName: "Overview",noteDetail: "The content is displayed here.The content is displayed here.The content is displayed here.The content is displayed here.The content is displayed here.")

        let model02 = DetailNoteItemModel(noteName: "Action Item",noteDetail: "The content is displayed here.The content is displayed here.The content is displayed here.The content is displayed here.The content is displayed here.")

        let model03 = DetailNoteItemModel(noteName: "Action Item",noteDetail: "The content is displayed here.The content is displayed here.The content is displayed here.The content is displayed here.The content is displayed here.")

        itemList = [model00,model01,model02,model03]
        tableView.reloadData()
        
        navTopView.updateFavorite(isFavorite: recordingItem!.isFavorite)
        tableHeaderView.updateData(timeStamp: recordingItem!.updateTime)
        tableHeaderView.updataNoteTitle(title: recordingItem!.recordFolder!)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}

// MARK: -  =====================DetailTableHeaderViewDelegate=========================
extension HomeNoteDetailViewController:DetailTableHeaderViewDelegate {
    func segmentTableHeaderViewClickIndex(index:Int){
        MyLog("segmentTableHeaderViewClickIndex \(index)")
        UserDefaultsTools.segmentIndex = index
    }
    func allNoteClick(){
        MyLog("allNoteClick")
        let content = HomeAllNotePopVC(recordingItem: recordingItem!)
        let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight - 60.h)
        content.dismissAction = {
            popup.dismissSelf()
        }
        UIApplication.topViewController()?.present(popup, animated: false)
    }
    func tableHeaderPlayClick(){
        MyLog("tableHeaderPlayClick")
    }
}

// MARK: -  =====================DetailSegmentViewDelegate=========================
extension HomeNoteDetailViewController:DetailSegmentViewDelegate {
    func segmentClickIndex(index:Int) {
        MyLog("segmentClickIndex \(index)")
        UserDefaultsTools.segmentIndex = index
        tableHeaderView.segmentV.segmentedView.setSelectedIndex(UserDefaultsTools.segmentIndex, animated: false)
    }
}

// MARK: -  =======================DetailNavTopViewDelegate========================
extension HomeNoteDetailViewController:DetailNavTopViewDelegate {
    func backClick(){
        MyLog("backClick")
        self.navigationController?.popViewController(animated: true)
    }
    func moreClick(){
        MyLog("moreClick")
        let menu = PopupMenu(
            items: [
                .init(title: L10n.editSummary, icon: Asset.editSummary.image),
                .init(title: L10n.editTranscript, icon: Asset.editTranscript.image),
                .init(title: L10n.translate, icon: Asset.translate.image),
                .init(title: L10n.delete, icon: Asset.delete.image, isDestructive: true)
            ]
        )

        menu.show(at: CGPoint(x: kkScreenWidth - 16.w, y: 88.h)) { index in
            print("点击了第 \(index) 项")
        }

    }
    func shareClick(){
        MyLog("shareClick")
    }
    func favoriteClick(){
        MyLog("favoriteClick")
        recordingItem?.isFavorite = !recordingItem!.isFavorite
        try! RecordingItemStore.shared.updateRecordingItem(recordingItem!)
        navTopView.updateFavorite(isFavorite: recordingItem!.isFavorite)
    }
}

// MARK: -  =======================DetailBottomViewDelegate========================
extension HomeNoteDetailViewController:DetailBottomViewDelegate {
    func refreshDetailBottomData(updatedText:String){
        MyLog(updatedText)
    }
    func refreshDetailBottomNoData(){
        MyLog("refreshDetailBottomNoData")
    }
    func bottomLeftClick(){
        MyLog("bottomLeftClick")
    }
    func bottomRightClick(){
        MyLog("bottomRightClick")
    }
}

//MARK: ----------TableViewDelegateDataSource-----------
extension HomeNoteDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = itemList[indexPath.row]
        let cell = tableView.dequeueCell(DetailNoteItemCell.self, for: indexPath)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let minOffsetY = -scrollView.adjustedContentInset.top
        if scrollView.contentOffset.y < minOffsetY {
            scrollView.contentOffset.y = minOffsetY
        }
        
        let offsetY = scrollView.contentOffset.y
        if offsetY >= showThreshold, !isControlVisible {
            showControl()
            isControlVisible = true
        } else if offsetY < showThreshold, isControlVisible {
            hideControl()
            isControlVisible = false
        }
        segmentV.segmentedView.setSelectedIndex(UserDefaultsTools.segmentIndex, animated: false)
    }
    
    private func showControl() {
        segmentV.isHidden = false
        navTopView.recordV.hidden(false)
        navTopView.backgroundColor(.white)
//        UIView.animate(withDuration: 0.25) { [self] in
//            segmentV.alpha = 1
//            segmentV.transform = .identity
//        }
    }

    private func hideControl() {
        segmentV.isHidden = true
        navTopView.recordV.hidden(true)
        navTopView.backgroundColor(kkColorFromHexWithAlpha("317DFF", 0.16))
//        UIView.animate(withDuration: 0.25, animations: { [self] in
//            segmentV.alpha = 0
//            segmentV.transform = CGAffineTransform(translationX: 0, y: 10)
//        }) { [self] _ in
//            segmentV.isHidden = true
//        }
    }


}

class DetailNoteItemCell: SuperTableViewCell {
    private var itemModel:DetailNoteItemModel? = nil
    private lazy var bgView = UIView().backgroundColor(kkColorFromHex(kkHomeBgColor)).cornerRadius(14.w)
    private lazy var titleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 18.h, weight: .bold)
    private lazy var subTitleL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .regular).lines(0)

    override func setUpUI() {
        self.backgroundColor(.clear)
        contentView.addChildView([bgView])
        bgView.addChildView([titleL,subTitleL])
        
        bgView.snp.makeConstraints { make in
            make.width.equalTo(343.w)
            make.height.equalTo(170.h)
            make.center.equalToSuperview()
        }
        
        titleL.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(16.h)
            make.height.equalTo(22.h)
        }
        
        subTitleL.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalTo(titleL.snp.bottom).offset(10.h)
            make.bottom.equalToSuperview().offset(-10.h)
        }

    }
    
    func configure(with item: DetailNoteItemModel) {
        itemModel = item
        titleL.text(item.noteName)
        subTitleL.text(item.noteDetail)
    }
}
