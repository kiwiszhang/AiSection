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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemList[indexPath.row]
        MyLog(item.itemName)
        if indexPath.row == 0 {
            do {
                if let data = recordingItem?.summarizationData {
                    let decoder = JSONDecoder()
                    let sentences = try decoder.decode(Summarization.self, from: data)
                    MyLog(sentences)
                    if let pdfURL = ShareHandlePDFTEXT.shared.generateTextPDF(title: sentences.title,pdfTitle:(recordingItem?.recordName)! + " " + L10n.summarize, body: sentences.paragraph) {
                        MyLog("✅ PDF summarizationData 导出成功: \(String(describing: pdfURL))")
                        let activityVC = UIActivityViewController(activityItems: [pdfURL as Any], applicationActivities: nil)
                        present(activityVC, animated: true)
                    }
                }else{
                    MBProgressHUD.showMessage(L10n.noSummarization)
                }
            } catch {
                MyLog("❌ Error: \(error.localizedDescription)")
                MBProgressHUD.showMessage(L10n.noSummarization)
            }
            
        }else if indexPath.row == 1 {
            do {
                if let data = recordingItem?.summarizationData {
                    let decoder = JSONDecoder()
                    let sentences = try decoder.decode(Summarization.self, from: data)
                    MyLog(sentences)
                    let content = sentences.title + sentences.paragraph
                    UIPasteboard.general.string = content
                    showAlertViewWithOutCancelButton(title: "",message: "已复制到剪贴板", confirmButtonTitle:"OK") { [self] confirmed in
                        dismissAction?()
                    }
                }else{
                    MBProgressHUD.showMessage(L10n.noSummarization)
                }
            } catch {
                MyLog("❌ Error: \(error.localizedDescription)")
                MBProgressHUD.showMessage(L10n.noSummarization)
            }
        }else if indexPath.row == 2 {
            do {
                if let data = recordingItem?.transcriptionData {
                    let decoder = JSONDecoder()
                    let sentences = try decoder.decode([AudioSentenceRaw].self, from: data)
                    MyLog(sentences)
                    
                    var content = ""
                    for sentItem in sentences {
                        let speaker = sentItem.speaker.name ?? ""
                        content += speaker + ": " + sentItem.content + "\n"
                    }
                    
                    if let pdfURL = ShareHandlePDFTEXT.shared.generateTextPDF(title: L10n.transcription,pdfTitle:(recordingItem?.recordName)! + " " + L10n.transcription, body: content) {
                        MyLog("✅ PDF Transcription 导出成功: \(String(describing: pdfURL))")
                        let activityVC = UIActivityViewController(activityItems: [pdfURL as Any], applicationActivities: nil)
                        present(activityVC, animated: true)
                    }
                }else{
                    MBProgressHUD.showMessage(L10n.noTranscription)
                }
            } catch {
                MyLog("❌ Error: \(error.localizedDescription)")
                MBProgressHUD.showMessage(L10n.noTranscription)
            }
        }else if indexPath.row == 3 {
            do {
                if let data = recordingItem?.transcriptionData {
                    let decoder = JSONDecoder()
                    let sentences = try decoder.decode([AudioSentenceRaw].self, from: data)
                    MyLog(sentences)
                    
                    var content = ""
                    for sentItem in sentences {
                        let speaker = sentItem.speaker.name ?? ""
                        content += speaker + ": " + sentItem.content + "\n"
                    }
                    UIPasteboard.general.string = content
                    showAlertViewWithOutCancelButton(title: "",message: "已复制到剪贴板", confirmButtonTitle:"OK") { [self] confirmed in
                        dismissAction?()
                    }
                }else{
                    MBProgressHUD.showMessage(L10n.noTranscription)
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
