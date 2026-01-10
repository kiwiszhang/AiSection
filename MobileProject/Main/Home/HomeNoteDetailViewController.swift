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
                let informationHtml = recordingItem!.informationHtml ?? ""
//                let summariztionHtml = recordingItem!.summariztionHtml ?? ""
                self.navigationController?.pushViewController(EditorSummaryViewController(recordingItem: recordingItem!,html: informationHtml), animated: true)
            }
            if index == 1 {
//                let transcriptionHtml = recordingItem!.transcriptionHtml ?? ""
//                self.navigationController?.pushViewController(EditorTranscriptViewController(recordingItem: recordingItem!,html: transcriptionHtml), animated: true)
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
        
        Task {
            do {
                let informationHtml = recordingItem!.informationHtml ?? ""
                let summariztionHtml = recordingItem!.summariztionHtml ?? ""
//                let result = try await translateText(
//                    text: cleanHTMLForNote(informationHtml + summariztionHtml),
//                    targetLanguage: seletedItem.localize
//                )
                
                let result = try await AIApiManager.shared.translate(textList: [informationHtml], targetLanguage: "en")
                
                print("翻译结果:", result)
            } catch {
                print("翻译失败:", error)
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
                if let htmlStr = recordingItem.informationHtml {
                    let processedHTML = HTMLPreprocessor.preprocess(htmlStr)
                     htmlLabel.attributedText = Self.makeAttributedHTML(
                         html: processedHTML,
                         font: UIFont.interBase(size: 14.h, weight: .regularBase),
                         textColor: .black
                     )
                }else{
                    var html = "<div><h1>Action Item</h1></div>";
                    do {
                        let decoder = JSONDecoder()
                        let sentences = try decoder.decode(InformationExtraction.self, from: recordingItem.informationData!)
                        MyLog("\(sentences.todoList)")
                        html += "<p><ul>"
                        if !sentences.todoList.isEmpty {
                            for item in sentences.todoList {
                                let content = item.content ?? ""
                                html += "<li>" + content + "</li>"
                            }
                        }
                        html += "</ul></p>"
//                        recordingItem.informationHtml = html
//                        try! RecordingItemStore.shared.updateRecordingItem(recordingItem)

                        let processedHTML = HTMLPreprocessor.preprocess(html)
                        htmlLabel.attributedText = Self.makeAttributedHTML(
                            html: processedHTML,
                            font: UIFont.interBase(size: 14.h, weight: .regularBase),
                            textColor: .black
                        )
                    } catch {
                        MyLog("\(error)")
                    }
                }
            } else if indexPath.row == 1 {
                if let htmlStr = recordingItem.summariztionHtml {
                let htmlStr01 = "<div class=\"test\"><h1>Action Item</h1><p></p><ul><li>根据军哥整理的资料，确定AI会议、密码图片编辑和图片编辑等产品的UI设计风格和时间节点</li></ul><div><b>然后</b>就会被别人发现你在</div><div><b>今天晚上你来接她了</b></div><div><b><i>然后再把你爸爸啊<u>点的东西给他送过去嘛</u></i></b></div><div><i><u>然后就会被</u></i></div><div><u>今天晚上不去ba</u></div><div><ol><li><u>今天爸爸</u></li><li>今天我去…。</li><li>然后再给自己的</li></ol><div>你说了就可以啊嘛你不是</div></div><div><ul><li>今天晚上不去上课咯</li><li>吧姐姐姐姐姐姐了</li></ul></div></div><blockquote style=\"margin: 0px 0px 0px 40px;\"><div class=\"test\"><div><div>然后再来问他有多</div></div><h1>今天晚上不回家b</h1></div></blockquote><h2>姐姐旅途</h2><h3>我想去吃烤</h3><div>我<span style=\"color: rgb(97, 23, 255);\">是A自己在外面吃饭了</span></div><div><font color=\"#6117ff\"><span style=\"caret-color: rgb(97, 23, 255);\"><b><i><u>我想姐姐了开卡礼、你不爸</u></i></b></span></font></div>"

//                    let processedHTML = HTMLPreprocessor.attributedString(from: htmlStr01, font: UIFont.italicSystemFont(ofSize: 14), textColor: .black)
//                    htmlLabel.attributedText = processedHTML
                    
                    let processedHTML = HTMLPreprocessor.preprocess(htmlStr)
                    htmlLabel.attributedText = Self.makeAttributedHTML(
                         html: processedHTML,
                         font: UIFont.interBase(size: 14.h, weight: .regularBase),
                         textColor: .black
                     )
                }else{
                    var html = "<div><h1>摘要</h1>";
                    do {
                        let decoder = JSONDecoder()
                        if let sumData = recordingItem.summarizationData {
                            let summarization = try decoder.decode(Summarization.self, from: sumData)
    //                        let title = markdownToSimpleHTML(summarization.title)
                            let title = summarization.title.replacingOccurrences(of: "\n", with: "<br />")
                            html += title
                            html += "<br />"
    //                        let paragraph = markdownToSimpleHTML(summarization.paragraph)
                            let paragraph = summarization.paragraph.replacingOccurrences(of: "\n", with: "<br />")
                            html += paragraph
                        }
                        html += "</div>"
//                        recordingItem.summariztionHtml = html
//                        try! RecordingItemStore.shared.updateRecordingItem(recordingItem)
                        let processedHTML = HTMLPreprocessor.preprocess(html)
                        htmlLabel.attributedText = Self.makeAttributedHTML(
                            html: processedHTML,
                            font: UIFont.interBase(size: 14.h, weight: .regularBase),
                            textColor: .black
                        )
                    } catch {
                        MyLog("\(error)")
                    }
                }
            }
        }else if UserDefaultsTools.segmentIndex == 1 {
//            
//            if let htmlStr = recordingItem.transcriptionHtml {
//                let processedHTML = HTMLPreprocessor.preprocess(htmlStr)
//                let start = CFAbsoluteTimeGetCurrent()
////                MBProgressHUD.showHUD()
//                htmlLabel.attributedText = Self.makeAttributedHTML(
//                    html: processedHTML,
//                    font: UIFont.interBase(size: 14.h, weight: .regularBase),
//                    textColor: .black
//                )
////                MBProgressHUD.hideHUD()
//                let end = CFAbsoluteTimeGetCurrent()
//                MyLog("⏱ [\("title")] 耗时：\((end - start) * 1000) ms")
//            }else{
//                var html = "<div><h1>转写</h1>"
//                do {
////                    let decoder = JSONDecoder()
////                    if let data = recordingItem.transcriptionData {
////                        let sentences = try decoder.decode([AudioSentenceRaw].self, from: data)
////                        if !sentences.isEmpty {
////                            for item in sentences {
////                                let content = item.content
////                                let speaker = item.speaker.name ?? "speaker"
////                                html += "<p>" + speaker + ": " + content + "</p>"
////                            }
////                        }
////                    }
////                    html += "</div>"
////                    let processedHTML = HTMLPreprocessor.preprocess(html)
////                    htmlLabel.attributedText = Self.makeAttributedHTML(
////                        html: processedHTML,
////                        font: UIFont.interBase(size: 14.h, weight: .regularBase),
////                        textColor: .black
////                    )
//                    let transcriptionData = recordingItem.transcriptionData
//                    let decoder = JSONDecoder()
//                    let sentences = try decoder.decode([AudioSentenceRaw].self, from: transcriptionData!)
//                    if !sentences.isEmpty {
//                        for item in sentences {
//                            let item01 = TranscriptionItemRequest(channel_id: -1, content: item.content, createTime: Int64(Date().timeIntervalSince1970), recordCreateTime: recordingItem.createTime, end_time: item.endTime, lang: item.lang, paragraph_id: Int16(item.paragraphID), sentence_id: Int16(item.sentenceID), speakerName: item.speaker.name ?? "", speakerType: Int16(item.speaker.type ?? 0), start_time: item.startTime, words: "")
//                            try! TranscriptionItemStore.shared.addTranscriptionItem(item01)
//                        }
//                    }
//                } catch {
//                    MyLog("\(error)")
//                }
//            }
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
