//
//  HomeViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/11.
//

import UIKit

let kSplitStringWithHtml = "<ol><ol><ol><ul><ul><ol><ul></ul></ol></ul></ul></ol></ol></ol>"

struct DetailNoteItemModel {
    var noteName: String = ""
    var noteDetail: String = ""
}

class HomeNoteDetailViewController: SuperViewController {
    private lazy var itemList:[DetailNoteItemModel] = []
    private lazy var itemTranscriptionList:[TranscriptionItem] = []
    var model:DetailNoteItemModel? = nil
    private lazy var recordingItem:RecordingItem? = nil
    private lazy var tableView = {
        return UITableView(frame: .zero, style: .grouped).delegate(self).dataSource(self).separatorStyle(.none).backgroundColor(.white).registerCells(HTMLTableViewCell.self).registerCells(TranscriptionTableViewCell.self).scrollEnable(true).headerHeight(0.01).footerHeight(0.01).clipsToBounds(true).registerHeaderFooters(SuperTableViewHeaderFooterView.self).rowHeightAutomaticDimension().showsH(false).showsV(false).estimatedRowHeight(100.h)
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
        navTopView.recordingItem = recordingItem
        tableHeaderView.recordingItem = recordingItem
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        UserDefaultsTools.segmentIndex = 0
        segmentV.segmentedView.setSelectedIndex(UserDefaultsTools.segmentIndex, animated: false)
        tableHeaderView.segmentV.segmentedView.setSelectedIndex(UserDefaultsTools.segmentIndex, animated: false)
        getData()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableHeaderView.stopAudios()
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
//
//        let model02 = DetailNoteItemModel(noteName: "Action Item",noteDetail: "The content is displayed here.The content is displayed here.The content is displayed here.The content is displayed here.The content is displayed here.")
//
//        let model03 = DetailNoteItemModel(noteName: "Action Item",noteDetail: "The content is displayed here.The content is displayed here.The content is displayed here.The content is displayed here.The content is displayed here.")

//        itemList = [model00,model01,model02,model03]
        if UserDefaultsTools.segmentIndex == 0 {
            itemList = [model00,model01]
        }else if UserDefaultsTools.segmentIndex == 1 {
            itemTranscriptionList = try! TranscriptionItemStore.shared.fetchTranscriptionItemWithRecordCreateTime(createTime: recordingItem!.createTime)
        }
        tableView.reloadData()
        
        navTopView.updateFavorite(isFavorite: recordingItem!.isFavorite)
        tableHeaderView.updateData(timeStamp: recordingItem!.updateTime)
        tableHeaderView.updataNoteTitle(title: recordingItem!.recordFolder!)
        navTopView.setUpPlay()
        tableHeaderView.setUpPlay()
        bottomView.bottonClick()
        
        
    }

}

// MARK: -  =====================DetailTableHeaderViewDelegate=========================
extension HomeNoteDetailViewController:DetailTableHeaderViewDelegate {
    func segmentTableHeaderViewClickIndex(index:Int){
        MyLog("segmentTableHeaderViewClickIndex \(index)")
        UserDefaultsTools.segmentIndex = index
        getData()
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
        getData()
    }
}

// MARK: -  =======================DetailNavTopViewDelegate========================
extension HomeNoteDetailViewController:DetailNavTopViewDelegate {
    func backClick(){
        MyLog("backClick")
        tableHeaderView.stopAudios()
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

        menu.show(at: CGPoint(x: kkScreenWidth - 16.w, y: 88.h)) { [self] index in
            MyLog("点击了第 \(index) 项")
            if index == 0 {
                let informationHtml = recordingItem!.todoJsonString ?? ""
                let summariztionHtml = recordingItem!.chapterSummaryJsonString ?? ""
//                self.navigationController?.pushViewController(EditorSummaryViewController(recordingItem: recordingItem!,html: informationHtml + kSplitStringWithHtml + summariztionHtml), animated: true)
                self.navigationController?.pushViewController(EditorViewController(recordingItem: recordingItem!,html: informationHtml), animated: true)
            }
            if index == 1 {
                UserDefaultsTools.segmentIndex = 1
                segmentV.segmentedView.setSelectedIndex(UserDefaultsTools.segmentIndex, animated: false)
                tableHeaderView.segmentV.segmentedView.setSelectedIndex(UserDefaultsTools.segmentIndex, animated: false)
                getData()
            }
            if index == 2 {
                let content = CenterLanguagePopVC()
                content.delegate = self
                let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight - 60.h)
                content.dismissAction = {
                    popup.dismissSelf()
                }
                self.present(popup, animated: false)
            }
            if index == 3 {
                try! RecordingItemStore.shared.delete(recordingItem!)
                self.navigationController?.popViewController(animated: true)
            }
        }

    }
    func shareClick(){
        MyLog("shareClick")
        let content = HomeSharePopViewController(itemList: HomeConfigData.getHomeMoreShareData(), recordingItem: recordingItem!)
        content.updateTitle(title: L10n.share)
        let popup = PopupContainerViewController(contentVC: content, height: 462.h)
        content.dismissAction = {
            popup.dismissSelf()
        }
        UIApplication.topViewController()?.present(popup, animated: false)
    }
    func favoriteClick(){
        MyLog("favoriteClick")
        recordingItem?.isFavorite = !recordingItem!.isFavorite
        try! RecordingItemStore.shared.updateRecordingItem(recordingItem!)
        navTopView.updateFavorite(isFavorite: recordingItem!.isFavorite)
    }
}

// MARK: -  =======================CenterLanguagePopVCDelegate========================
extension HomeNoteDetailViewController:CenterLanguagePopVCDelegate {
    func selectedLangitem(seletedItem: LangItem){
        MyLog("selectedLangitem")
        MyLog(seletedItem)
        UserDefaultsTools.fanyiYuYanTitle = seletedItem.title
        UserDefaultsTools.fanyiYuYanSelected = seletedItem.transLocalize
        Task { @MainActor in
            MBProgressHUD.showHUD()
            defer {
                MBProgressHUD.hideHUD()
            }
            do {
                let informationHtml = recordingItem?.todoJsonString ?? ""
                let jsonString = try await requestDoubaoContent(
                    html: informationHtml,
                    targetLang: UserDefaultsTools.fanyiYuYanSelected
                )
                recordingItem?.todoJsonString = jsonString

                let summariztionHtml = recordingItem?.chapterSummaryJsonString ?? ""
                let jsonString01 = try await requestDoubaoContent(
                    html: summariztionHtml,
                    targetLang: UserDefaultsTools.fanyiYuYanSelected
                )
                recordingItem?.chapterSummaryJsonString = jsonString01

                try RecordingItemStore.shared.updateRecordingItem(recordingItem!)
                getData()

            } catch {
                MyLog("翻译失败: \(error)")
            }
        }


    }
    
    func htmlToPlainText(_ html: String) -> String {
        guard let data = html.data(using: .utf8) else { return html }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        let attributedString = try? NSAttributedString(
            data: data,
            options: options,
            documentAttributes: nil
        )

        return attributedString?.string ?? html
    }
    func cleanHTMLForNote(_ html: String) -> String {
        let text = htmlToPlainText(html)
        return text
            .replacingOccurrences(of: "\n\n\n", with: "\n\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
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
        self.navigationController?.pushViewController(ChatViewController(recordingItem: recordingItem!), animated: true)
    }
    func bottomRightClick(){
        MyLog("bottomRightClick")
        self.navigationController?.pushViewController(ChatViewController(recordingItem: recordingItem!), animated: true)
    }
    func bottomClick(){
        self.navigationController?.pushViewController(ChatViewController(recordingItem: recordingItem!), animated: true)
    }
}

//MARK: ----------TableViewDelegateDataSource-----------
extension HomeNoteDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserDefaultsTools.segmentIndex == 0 {
            return itemList.count
        }else if UserDefaultsTools.segmentIndex == 1 {
            return itemTranscriptionList.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if UserDefaultsTools.segmentIndex == 0 {
            let cell = tableView.dequeueCell(HTMLTableViewCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.configure(recordingItem: recordingItem!,indexPath: indexPath)
            return cell
        } else if UserDefaultsTools.segmentIndex == 1 {
            let cell = tableView.dequeueCell(TranscriptionTableViewCell.self, for: indexPath)
            cell.selectionStyle = .none
            let tItem = itemTranscriptionList[indexPath.row]
            cell.configure(with: tItem, recordingItem: recordingItem!)
            cell.editCallback = { [weak self] newText in
                guard let self else { return }
                tItem.content = newText
                try! TranscriptionItemStore.shared.updateTranscriptionItem(tItem)
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }

            return cell
        }
        return UITableViewCell()
//        cell.configure(with: model,recordingItem: recordingItem!)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = itemList[indexPath.row]
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
    }

    private func hideControl() {
        segmentV.isHidden = true
        navTopView.recordV.hidden(true)
        navTopView.backgroundColor(kkColorFromHexWithAlpha("317DFF", 0.16))
    }


}

final class HTMLTableViewCell: SuperTableViewCell {

    // MARK: - UI
    private lazy var bgView = UIView().backgroundColor(kkColorFromHex(kkHomeBgColor)).cornerRadius(14.h)
    private lazy var htmlLabel = UILabel().backgroundColor(.clear).lines(0)
    override func setUpUI() {
        selectionStyle = .none
        contentView.addSubview(bgView)
        bgView.addSubview(htmlLabel)
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.w)
            make.right.equalToSuperview().offset(-16.w)
            make.top.equalToSuperview().offset(8.w)
            make.bottom.equalToSuperview().offset(-8.w)
        }

        htmlLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8.h)
            make.bottom.equalToSuperview().offset(-8.h)
            make.left.equalToSuperview().offset(10.w)
            make.right.equalToSuperview().offset(-10.w)
        }
        
    }

    // MARK: - Public

    func configure(recordingItem:RecordingItem,indexPath: IndexPath) {
        
        if UserDefaultsTools.segmentIndex == 0 {
            if indexPath.row == 0 {
                
                let html = "<div><h1>Action Item</h1></div><p><ol><li>完成图片编辑类APP 1.0版本的需求文档和原型输出</li><li>完成拼图的视频编辑功能2.0原型修改</li><li>推动Flash Boys 2.0版本的模板和活动两个模块</li><li>完成扫描记账的英语、简体中文、繁体中文规划和数据撰写</li><li>完成Flash boots的泰国、越南的商家图规划和数据撰写</li><li>完成扫描记账和Flash boots的自定义页面规划</li><li>对接志祥，校验前面引导及订阅页的界面还原度和动画效果，并优化冥想模块细节</li><li>完成新增PDF功能模块的设计</li><li>完成拼图剩余网格设计</li><li>完成拼图2.0的高级版、超级版的引导订阅页的设计以及动画规划</li><li>完成视频编辑板块的流程设计</li><li>做一版不同背景色、排版的Flash Boys英文版上下图优化版本，制作泰国、越南上下图，及时修改饮品面积</li><li>若有修改需求，修改Fresh Books的logo和扫描记账的相关设计</li><li>完成睡眠APP新功能文本的现有全语种本地化，完成拼图APP新订阅页、积分制新功能现有全语种本地化，继续补充完善通用娱乐和专业娱乐产品</li><li>完成剩余的AI扩图功能及其他AI功能</li><li>完成女性模板拼接及所有模板处理</li><li>对已完成的睡眠项目进行查漏补缺、测试和修复</li><li>开发Freshworks的模板</li><li>继续添加设计制作出的不同模板到网格拼图功能中</li><li>接入SDK，实现音频APP音频工具对应的功能，争取周五打出初步版本</li><li>将工作重心转向新品开发，对现有工作做收尾节点</li><li>研究几个新品的技术方向，做前期准备</li><li>产品加快新品开发进度，修改产品需求</li><li>UI尽快进入新品设计，先确定首页等两三个页面，出1 - 2版设计内容</li><li>研发在UI出图后，开小会快速确定1.0版本功能，做项目前期准备和技术规划</li><li>李程以图片编辑产品为主，确定版本并规划技术性内容</li><li>方斌在3周内完成拼图项目基础测试和基础bug调试</li><li>志祥和李成在一周内完成拼图另外两个功能</li><li>1 - 2周内完成睡眠项目bug修复等工作</li><li>12月底完成音频编辑功能实现</li><li>周慧与军哥同步市场投放情况、基础报表、品的整体方向、市场期望、功能方向等，与产品进一步沟通产品迭代方向和进程</li><li>分析扫描记账和For boss的核心关键词、CPP主要国家投放情况、单个下载成本等数据，与SO同步数据，根据数据调整页面优化和落地页迭代</li><li>确定音频新品上线账号，调整时间周期，确定上线前核心关键词等准备工作负责人</li><li>UI人员自由搭配负责新品设计，提前调研竞品，邓凡留1 - 2天做新品调研和前期准备工作</li><li>军哥整理几个新品前期调研的东西，与UI和产品一起过一下，确定人员安排</li></ol></p>"
                let isTest = false
                
                if let htmlStr = recordingItem.todoJsonString,htmlStr.contains(str: "<div>") {
                    
                    var processedHTML = ""
                    if isTest {
                        processedHTML = HTMLPreprocessor.preprocess(html)
                        recordingItem.todoJsonString = processedHTML
                        try! RecordingItemStore.shared.updateRecordingItem(recordingItem)
                    }else{
                        processedHTML = HTMLPreprocessor.preprocess(htmlStr)
                    }

                     htmlLabel.attributedText = Self.makeAttributedHTML(
                         html: processedHTML,
                         font: UIFont.interBase(size: 14.h, weight: .regularBase),
                         textColor: .black
                     )
                }else{
                    var html = "<div><h1>\(L10n.actionItem)</h1></div>";
                    let arr = [String].fromJSONString(recordingItem.todoJsonString!)
                    html += "<p><ol>"
                    if !arr!.isEmpty {
                        for item in arr! {
                            html += "<li>" + item + "</li>"
                        }
                    }
                    html += "</ol></p>"
                recordingItem.todoJsonString = html
                try! RecordingItemStore.shared.updateRecordingItem(recordingItem)
                    let processedHTML = HTMLPreprocessor.preprocess(html)
                    htmlLabel.attributedText = Self.makeAttributedHTML(
                        html: processedHTML,
                        font: UIFont.interBase(size: 14.h, weight: .regularBase),
                        textColor: .black
                    )
                }
            } else if indexPath.row == 1 {
                if let htmlStr = recordingItem.chapterSummaryJsonString, htmlStr.contains(str: "<div>") {
                    let processedHTML = HTMLPreprocessor.preprocess(htmlStr)
                    htmlLabel.attributedText = Self.makeAttributedHTML(
                         html: processedHTML,
                         font: UIFont.interBase(size: 14.h, weight: .regularBase),
                         textColor: .black
                     )
                }else{
                    do{
                        var html = "<div><h1>\(L10n.chaptersummary)</h1>";
                        let data = recordingItem.chapterSummaryJsonString!.data(using: .utf8)!
                        let chapters = try JSONDecoder().decode([ChapterSummary].self, from: data)
                        if !chapters.isEmpty {
                            for item in chapters {
                                html += "<h3>" + item.title + "</h3>"
                                html += "<ol>"
                                for content in item.content {
                                    html += "<li>" + content + "</li>"
                                }
                                html += "</ol>"
                            }
                        }
                        html += "</div>";
                        recordingItem.chapterSummaryJsonString = html
                        try! RecordingItemStore.shared.updateRecordingItem(recordingItem)
                        let processedHTML = HTMLPreprocessor.preprocess(html)
                        htmlLabel.attributedText = Self.makeAttributedHTML(
                            html: processedHTML,
                            font: UIFont.interBase(size: 14.h, weight: .regularBase),
                            textColor: .black
                        )
                    }catch{
                        MyLog(error)
                    }
                }
            }
        }else if UserDefaultsTools.segmentIndex == 1 {

        }
    }
}

extension HTMLTableViewCell {

    static func makeAttributedHTML(html: String,
                                    font: UIFont,
                                    textColor: UIColor) -> NSAttributedString {

        let wrappedHTML = wrapHTML(html, font: font, textColor: textColor)
            guard let data = wrappedHTML.data(using: .utf8) else {
                return NSAttributedString()
            }

            return (try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )) ?? NSAttributedString()
    }

    static func wrapHTML(_ body: String, font: UIFont, textColor: UIColor) -> String {

        let colorHex = textColor.hexString

        return """
        <html>
        <head>
            <meta charset="utf-8">
            <style>
                body {
                    font-family: -apple-system;
                    font-size: \(font.pointSize)px;
                    color: \(colorHex);
                    margin: 0;
                    padding: 0;
                }

                p {
                    margin: 4px 0;
                }

                h1 { font-size: 20px; margin: 8px 0; }
                h2 { font-size: 18px; margin: 8px 0; }
                h3 { font-size: 16px; margin: 6px 0; }

                ul, ol {
                    margin: 6px 0 6px 18px;
                    padding: 0;
                }

                li {
                    margin: 4px 0;
                }

                blockquote {
                    margin-left: 12px;
                    padding-left: 8px;
                    border-left: 3px solid #ddd;
                    color: #666;
                }
            </style>
        </head>
        <body>
            \(body)
        </body>
        </html>
        """
    }
}

extension UIColor {
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(
            format: "#%02X%02X%02X",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }
}


class TranscriptionTableViewCell: SuperTableViewCell,UITextViewDelegate {
    private lazy var bgView = UIView().backgroundColor(kkColorFromHex(kkHomeBgColor)).cornerRadius(14.w)
    private lazy var titleL = UILabel().text("00:00").color(kkColorFromHex(kkSubTitleColor)).hnFont(size: 14.h, weight: .regular)
    private lazy var contentL = UILabel().text("title").color(kkColorFromHex(kkMainTitleColor)).hnFont(size: 14.h, weight: .regular).lines(0)
    private lazy var contentTextView = UITextView().text("").hnFont(size: 14.h, weight: .regular).color(kkColorFromHex(kkMainTitleColor)).hidden(true).backgroundColor(.clear).delegate(self)


    private lazy var editerImg = UIImageView().image(Asset.chatTrans.image).enable(true).onTap {
        MyLog("editerImg")
        self.toggleEdit()
    }
    
    private var isEditingContent = false
    var editCallback: ((String) -> Void)?

    override func setUpUI() {
        self.backgroundColor(.clear)
        contentView.addChildView([bgView])
        bgView.addChildView([titleL,contentL,contentTextView,editerImg])
        
        bgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8.h)
            make.bottom.equalToSuperview().offset(-8.h)
            make.left.equalToSuperview().offset(24.w)
            make.right.equalToSuperview().offset(-24.w)
        }
        
        titleL.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(15.h)
            make.height.equalTo(17.h)
        }
        
        contentL.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalTo(titleL.snp.bottom).offset(10.h)
            make.bottom.equalToSuperview().offset(-10.h)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalTo(titleL.snp.bottom).offset(10.h)
            make.bottom.equalToSuperview().offset(-10.h)
        }

        editerImg.snp.makeConstraints { make in
            make.width.height.equalTo(24.h)
            make.right.equalToSuperview().offset(-8.w)
            make.top.equalToSuperview().offset(8.h)
        }
        contentTextView.isScrollEnabled = false
        contentTextView.textContainerInset = .zero
        contentTextView.textContainer.lineFragmentPadding = 0

    }
    func configure(with item: TranscriptionItem,recordingItem:RecordingItem) {
        titleL.text(formatTime(item.start_time))
        contentL.text(item.content)
    }
    
    func formatTime(_ time: Double) -> String {
        let totalSeconds = Int(time / 1000)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        exitEditMode()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        isEditingContent = true
    }

    func textViewDidChange(_ textView: UITextView) {
        guard isEditingContent else { return }
        notifyTableViewUpdate()
    }

    private func notifyTableViewUpdate() {
        if let tableView = findTableView() {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }

    private func findTableView() -> UITableView? {
        var view = self.superview
        while view != nil {
            if let tableView = view as? UITableView {
                return tableView
            }
            view = view?.superview
        }
        return nil
    }


    private func exitEditMode() {
        guard isEditingContent else { return }
        isEditingContent = false

        let newText = contentTextView.text ?? ""
        contentL.text = newText

        contentTextView.resignFirstResponder()
        contentTextView.isHidden = true
        contentL.isHidden = false

        editCallback?(newText)
    }

    private func enterEditMode() {
        isEditingContent = true
        contentTextView.text = contentL.text
        contentTextView.isHidden = false
        contentL.isHidden = true
        contentTextView.becomeFirstResponder()
    }

    private func toggleEdit() {
        isEditingContent ? exitEditMode() : enterEditMode()
    }

}
