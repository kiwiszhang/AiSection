//
//  CenterClickPopViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/12.
//

import UIKit
import UniformTypeIdentifiers

struct HandleRecordingState {
    let handleStatus: Int
    let handleContent: String
}

class CenterAudioPopViewController: SuperViewController {

    var dismissAction: (() -> Void)?
    private var fDestURL:URL?
    private var destLang:String = "en_us"
    private var selectedFolderItem:FolderItem? = nil
    private lazy var barView = PopTopView()
    private lazy var audioView = TitleFieldView()
    private lazy var languageView = TitleFieldView()
    private lazy var floderView = TitleFieldView()
    private lazy var getBtn = UILabel().text(L10n.getSummary).hnFont(size: 18.h, weight: .medium).color(.white).backgroundColor(kkColorFromHex(kkMainColor)).centerAligned().cornerRadius(14.h).onTap { [self] in
        MyLog("getBtn")

        guard let destURL = fDestURL else {return}
        guard let fileName = UtitilTools.relativePathFromDocuments(for: destURL) else { return }

        var folderName00 = ""
        var recordFolderId00 = ""
        if let selectedFolderModel = selectedFolderItem {
            folderName00 = selectedFolderModel.folderName!
            recordFolderId00 = selectedFolderModel.recordFolderId!
        }else{
            folderName00 = ""
            recordFolderId00 = UUID().uuidString
        }
        var item00 = RecordingItemRequest(updateTime: Int64(Date().timeIntervalSince1970), recordType: 0, handleType: 1, recordPath: destURL.lastPathComponent, recordName: destURL.deletingPathExtension().lastPathComponent, recordFolder: folderName00, recordFolderId: recordFolderId00, isFavorite: false, createTime: Int64(Date().timeIntervalSince1970), transcriptionData: nil)
        
        try! RecordingItemStore.shared.addRecordingItem(item00)
        
        let coreDataItem = try! RecordingItemStore.shared.fetchByFolderId(item00.recordFolderId!).first

        UploadRecord.shared.uploadFile(fileName: fileName,fileURL:URL(string: destURL.absoluteString)!) { [self] task in
            if ((task.error == nil)) {
                UtitilTools.broadcast(handleStatus: 2, handleContent: "开始处理录音，录音文件上传成功")
                MyLog("Put object from file success.");
                let output = task.result;
                MyLog(output)
                
                let client = ByteDanceOpenSpeechClient(
                    config: .init(
                        appKey: XApiAppKey,
                        accessKey: XApiAccessKey,
                        resourceId: XApiResourceId
                    )
                )
                
                Task {
                    do {
                        let queryData = try await SubmitAndQueryHandle.shared.handleRecord(fileName: fileName, client: client)
                            if queryData.ErrCode == 0 && queryData.Status == "success"{
                                UtitilTools.broadcast(handleStatus: 3, handleContent: "开始处理录音，录音文件转写成功")
                                coreDataItem?.handleType = 1
                                try! RecordingItemStore.shared.updateRecordingItem(coreDataItem!)
                                if let url = queryData.Result?.AudioTranscriptionFile {
                                    do {
                                        let transcriptionData = try await client.fetchAudioTranscriptionData(from: url)
                                        coreDataItem!.transcriptionData = transcriptionData
                                        try! RecordingItemStore.shared.updateRecordingItem(coreDataItem!)
                                    } catch {
                                        MyLog("❌ Error: \(error.localizedDescription)")
                                    }
                                }
                                if let url = queryData.Result?.ChapterFile {
                                    do {
                                        let chapterSummaryData = try await client.fetchChapterFileData(from: url)
                                        coreDataItem!.chapterSummaryData = chapterSummaryData
                                        try! RecordingItemStore.shared.updateRecordingItem(coreDataItem!)
                                    } catch {
                                        MyLog("❌ Error: \(error.localizedDescription)")
                                    }
                                }
                                
                                if let url = queryData.Result?.InformationExtractionFile {
                                    do {
                                        let informationData = try await client.fetchInformationExtractionFileData(from: url)
                                        coreDataItem!.informationData = informationData
                                        try! RecordingItemStore.shared.updateRecordingItem(coreDataItem!)
                                    } catch {
                                        MyLog("❌ Error: \(error.localizedDescription)")
                                    }
                                }
                                
                                if let url = queryData.Result?.SummarizationFile {
                                    do {
                                        let summarizationData = try await client.fetchSummarizationFileData(from: url)
                                        coreDataItem!.summarizationData = summarizationData
                                        try! RecordingItemStore.shared.updateRecordingItem(coreDataItem!)
                                        UtitilTools.broadcast(handleStatus: 4, handleContent: "处理录音，录音文件总结处理完成")
                                    } catch {
                                        MyLog("❌ Error: \(error.localizedDescription)")
                                    }
                                }
                                
                                if let url = queryData.Result?.TranslationFile {
                                    do {
                                        let translationData = try await client.fetchTranslationFileData(from: url)
                                        coreDataItem!.translationData = translationData
                                        try! RecordingItemStore.shared.updateRecordingItem(coreDataItem!)
                                    } catch {
                                        MyLog("❌ Error: \(error.localizedDescription)")
                                    }
                                }
                            }
                        // 成功
                    } catch {
                        MyLog("❌ 外层收到错误：\(error)")
                        coreDataItem?.handleType = -1
                        try! RecordingItemStore.shared.updateRecordingItem(coreDataItem!)
                        UtitilTools.broadcast(handleStatus: 0, handleContent: "录音处理失败")
                    }
                }

            } else {
                coreDataItem?.handleType = -1
                try! RecordingItemStore.shared.updateRecordingItem(coreDataItem!)
                UtitilTools.broadcast(handleStatus: 0, handleContent: "录音处理失败")
                MyLog("Put object from file failed, error: \(String(describing: task.error))");
            }
        }
        UtitilTools.broadcast(handleStatus: 1, handleContent: "开始处理录音，上传录音文件")
        coreDataItem?.handleType = 0
        try! RecordingItemStore.shared.updateRecordingItem(coreDataItem!)
        let vc = CenterProcessingVC()
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setUpUI() {
        view.addChildView([barView,audioView,languageView,floderView,getBtn])

        barView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(80.h)
        }

        audioView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalTo(barView.snp.bottom).offset(5.h)
            make.height.equalTo(82.h)
        }
        
        languageView.snp.makeConstraints { make in
            make.left.height.right.equalTo(audioView)
            make.top.equalTo(audioView.snp.bottom).offset(20.h)
        }
        
        floderView.snp.makeConstraints { make in
            make.left.height.right.equalTo(audioView)
            make.top.equalTo(languageView.snp.bottom).offset(20.h)
        }
        
        getBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalTo(floderView.snp.bottom).offset(40.h)
            make.height.equalTo(50.h)
        }
        
        
    }

    override func getData() {
        barView.delegate = self
        barView.updateData(title: L10n.uploadVideo)
        
        audioView.delegate = self
        audioView.updateData(title: L10n.audioFiles, prompTitle: L10n.fileName,isShowDowm: true)
        
        languageView.delegate = self
        languageView.updateData(title: L10n.languageOfSummaryTranscript, prompTitle: L10n.automatic,isShowDowm: true)
        
        floderView.delegate = self
        floderView.updateData(title: L10n.folder, prompTitle: L10n.none,isShowDowm: true)
        
        getBtn.enable(false).alpha(0.4)
    }

}


// MARK: -  =======================PopTopViewDelegate========================
extension CenterAudioPopViewController:PopTopViewDelegate {
    func popTopViewClose() {
        dismissAction?()
    }
}

// MARK: -  =======================TitleFieldViewDelegate========================
extension CenterAudioPopViewController:TitleFieldViewDelegate {
    func refreshData(updatedText:String,selfView:TitleFieldView){
        if selfView == audioView {
            MyLog("audioView")
        }else if selfView == languageView {
            MyLog("languageView")
        }else if selfView == floderView {
            MyLog("floderView")
        }
    }
    func refreshNoData(selfView:TitleFieldView){
        if selfView == audioView {
            MyLog("refreshNoData---audioView")
        }else if selfView == languageView {
            MyLog("refreshNoData---languageView")
        }else if selfView == floderView {
            MyLog("refreshNoData---floderView")
        }
    }
    
    func clickDowm(selfView:TitleFieldView){
        if selfView == audioView {
            MyLog("clickDowm---audioView")
            presentAudioPicker(from: self)
        }else if selfView == languageView {
            MyLog("clickDowm---languageView")
            let content = CenterLanguagePopVC()
            content.delegate = self
            let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight - 60.h)
            content.dismissAction = {
                popup.dismissSelf()
            }
            self.present(popup, animated: false)
            
        }else if selfView == floderView {
            MyLog("clickDowm---floderView")
            let content = HomeNoAllNotePopVC(recordingItem: nil)
            content.delegate = self
            let popup = PopupContainerViewController(contentVC: content, height: kkScreenHeight - 60.h)
            content.dismissAction = {
                popup.dismissSelf()
            }
            UIApplication.topViewController()?.present(popup, animated: false)
        }
    }
    
    func presentAudioPicker(from vc: UIViewController) {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.audio],
            asCopy: true
        )
        picker.delegate = self
        picker.allowsMultipleSelection = false
        vc.present(picker, animated: true)
    }
}

// MARK: -  =======================CenterProcessingVCDelegate========================
extension CenterAudioPopViewController:CenterProcessingVCDelegate {
    func backDismissProcessing() {
        dismissAction?()
    }
}

// MARK: -  =======================HomeNoAllNotePopVCDelegate========================
extension CenterAudioPopViewController:HomeNoAllNotePopVCDelegate {
    func selectedFolderItem(folderItem: FolderItem){
        MyLog("selectedFolderItem")
        floderView.updateContent(content: folderItem.folderName!)
        selectedFolderItem = folderItem
    }
}

// MARK: -  =======================CenterLanguagePopVCDelegate========================
extension CenterAudioPopViewController:CenterLanguagePopVCDelegate {
    func selectedLangitem(seletedItem: LangItem){
        MyLog("selectedLangitem")
        MyLog(seletedItem)
        languageView.updateContent(content: seletedItem.subTitle)
        destLang = seletedItem.localize
    }
}

// MARK: -  =======================UIDocumentPickerDelegate========================
extension CenterAudioPopViewController: UIDocumentPickerDelegate {
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let url = urls.first else { return }
        let access = url.startAccessingSecurityScopedResource()
        defer {
            if access {
                url.stopAccessingSecurityScopedResource()
            }
        }
        MyLog("选中的音频文件:\(url)")
        
        let fileName = url.lastPathComponent
        audioView.updateContent(content: fileName)

        getBtn.enable(true).alpha(1)
        // 拷贝到 App 沙盒
        saveToSandboxIfNeeded(url)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        MyLog("用户取消选择")
    }
    
    func saveToSandboxIfNeeded(_ url: URL) {
        let fileManager = FileManager.default

        // Documents 目录
        let documentsURL = fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)[0]

        // Documents/Recording
        let recordingDir = documentsURL.appendingPathComponent("Recording", isDirectory: true)

        // 确保 Recording 目录存在
        if !fileManager.fileExists(atPath: recordingDir.path) {
            do {
                try fileManager.createDirectory(
                    at: recordingDir,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                MyLog("创建 Recording 目录失败:\(error)")
                return
            }
        }

        // 最终文件路径
        let destURL = recordingDir.appendingPathComponent(url.lastPathComponent)
        fDestURL = destURL
        // 已存在直接返回
        if fileManager.fileExists(atPath: destURL.path) {
            MyLog("文件已存在:\(destURL)")
            return
        }

        // 拷贝文件
        do {
            try fileManager.copyItem(at: url, to: destURL)
            MyLog("已保存到 Documents/Recording:\(destURL)")
            fDestURL = destURL
        } catch {
            MyLog("拷贝失败:\(error)")
            fDestURL = nil
        }
    }
}
