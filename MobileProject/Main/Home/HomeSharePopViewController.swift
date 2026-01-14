//
//  HomePopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/13.
//

import UIKit

class HomeSharePopViewController: SuperViewController {

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
    
    func updateTitle(title:String){
        barView.updateData(title: title)
    }

}

// MARK: -  =======================PopTopViewDelegate========================
extension HomeSharePopViewController:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
}

// MARK: -  =======================HomeAddFloderPopVCDelegate========================
extension HomeSharePopViewController:HomeAddFloderPopVCDelegate {
    func addFloderSave(Floder:String) {
        dismissAction?()
        recordingItem?.recordName = Floder
        try! RecordingItemStore.shared.updateRecordingItem(recordingItem!)
        tableView.reloadData()
    }
}


//MARK: ----------TableViewDelegateDataSource-----------
extension HomeSharePopViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    func exportPDF(html: String,fileName:String) {
        PDFTextExporter.export(htmlContent: html,fileName:fileName) { result in
            switch result {
            case .success(let url):
                print("PDF生成成功: \(url)")
                DispatchQueue.main.async {
                        let vc = UIActivityViewController(
                            activityItems: [url],
                            applicationActivities: nil
                        )
                    self.present(vc, animated: true)
                }
            case .failure(let error):
                print("生成失败: \(error)")
            }
        }
    }
    
    func htmlToPlainTextPreserveLineBreaks(_ html: String) -> String {
        var text = html

        // 1️⃣ 将换行相关的标签替换为 \n
        let breakTags = ["<br>", "<br/>", "<br />", "<p>", "</p>", "<li>", "</li>", "<h1>", "</h1>", "<h2>", "</h2>", "<h3>", "</h3>", "<h4>", "</h4>", "<h5>", "</h5>", "<h6>", "</h6>"]
        for tag in breakTags {
            text = text.replacingOccurrences(of: tag, with: "\n", options: .caseInsensitive, range: nil)
        }

        // 2️⃣ 删除所有其他 HTML 标签
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)

        // 3️⃣ 替换连续多个换行符为两个换行符（防止太多空行）
        let multipleNewlinesRegex = try! NSRegularExpression(pattern: "\n{2,}", options: [])
        text = multipleNewlinesRegex.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count), withTemplate: "\n\n")

        // 4️⃣ 去掉前后空格
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)

        return text
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemList[indexPath.row]
        MyLog(item.itemName)
        if indexPath.row == 0 {
            if let data = recordingItem?.todoJsonString {
                let html = data + (recordingItem?.chapterSummaryJsonString ?? " ")
                exportPDF(html: html,fileName: (recordingItem?.recordName)! + "Summary.pdf")
            }else{
                MBProgressHUD.showMessage(L10n.noSummarization)
            }
        }else if indexPath.row == 1 {
            if let data = recordingItem?.todoJsonString {
                var content = data + (recordingItem?.chapterSummaryJsonString ?? " ")
                content = htmlToPlainTextPreserveLineBreaks(content)
                UIPasteboard.general.string = content
                showAlertViewWithOutCancelButton(title: "",message: L10n.copyTopastBorad, confirmButtonTitle:L10n.ok) { [self] confirmed in
                    dismissAction?()
                }
            }else{
                MBProgressHUD.showMessage(L10n.noSummarization)
            }
        }else if indexPath.row == 2 {
            do {
                let transArr = try TranscriptionItemStore.shared.fetchTranscriptionItemWithRecordCreateTime(createTime: recordingItem!.createTime)
                if transArr.isEmpty {
                    MBProgressHUD.showMessage(L10n.noTranscription)
                }else{
                    var html = "<ul>"
                    for item in transArr {
                        html += "<li>" + (item.speakerName ?? "") + ":" + (item.content ?? "") + "</li>"
                    }
                    html += "</ul>"
                    exportPDF(html: html,fileName: (recordingItem?.recordName)! + "Transcription.pdf")
                }
            } catch {
                MyLog("❌ Error: \(error.localizedDescription)")
                MBProgressHUD.showMessage(L10n.noTranscription)
            }
        }else if indexPath.row == 3 {
            do {
                let transArr = try TranscriptionItemStore.shared.fetchTranscriptionItemWithRecordCreateTime(createTime: recordingItem!.createTime)
                if transArr.isEmpty {
                    MBProgressHUD.showMessage(L10n.noTranscription)
                }else{
                    var content = ""
                    for item in transArr {
                        content += (item.content ?? "") + "\n"
                    }
                    UIPasteboard.general.string = content
                    showAlertViewWithOutCancelButton(title: "",message: L10n.copyTopastBorad, confirmButtonTitle:L10n.ok) { [self] confirmed in
                        dismissAction?()
                    }
                }
            } catch {
                MyLog("❌ Error: \(error.localizedDescription)")
                MBProgressHUD.showMessage(L10n.noTranscription)
            }
        }else if indexPath.row == 4 {
            if let urlPath = UtitilTools.documentsURL(for: "Recording/" + (recordingItem?.recordPath!)!) {
                ShareManager.shared.shareURL(urlPath,title: recordingItem?.recordName)
            }else{
                MBProgressHUD.showMessage(L10n.noFile)
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
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//        }
//    }
//    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
//        for cell in tableView.visibleCells {
//        }
//    }
}
