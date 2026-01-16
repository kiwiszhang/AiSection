//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//

import AVFoundation
final class AudioProcessingPipeline {
    static let shared = AudioProcessingPipeline()
    private let uploadService = UploadRecord.shared
    private let asrService = ASRTaskManager(
        appID: XApiAppKey,
        token: XApiAccessKey
    )
    private init() {}
    
    // MARK: - Public Entry
    func process(
        fileName: String,
        fileURL: URL,
        recordingItem: RecordingItem
    ) {
        DispatchQueue.main.async {
            MBProgressHUD.showMessage(L10n.uploadrecord)
        }

        uploadService.uploadFile(fileName: fileName, fileURL: fileURL) { task in
            guard task.error == nil else {
                self.fail(recordingItem)
                return
            }

            UtitilTools.broadcast(handleStatus: 2, handleContent: "录音上传成功，开始识别")
            
            let audioURL = "https://aisection.tos-cn-beijing.volces.com/" + fileName

            Task {
                do {
                    
                    recordingItem.handleType = 2
                    recordingItem.updateTime = Int64(Date().timeIntervalSince1970)
                    try RecordingItemStore.shared.updateRecordingItem(recordingItem)
                    
                    DispatchQueue.main.async {
                        MBProgressHUD.showMessage(L10n.transcribingrecord)
                    }
                    let response = try await self.asrService.transcribe(
                        audioURL: audioURL,
                        format: "mp3",
                        language: UserDefaultsTools.transcritionSelected
                    )
                    DispatchQueue.main.async {
                        MBProgressHUD.showMessage(L10n.saveResultRecord)
                    }
                    try await self.handleASRResult(
                        response,
                        recordingItem: recordingItem
                    )
                    DispatchQueue.main.async {
                        MBProgressHUD.showMessage(L10n.generateAiSummary)
                    }
                    try await self.handleAISummary(response.result?.text, recordingItem)
                    DispatchQueue.main.async {
                        MBProgressHUD.hideHUD()
                    }
                } catch {
                    DispatchQueue.main.async {
                        MBProgressHUD.hideHUD()
                    }
                    self.fail(recordingItem)
                }
            }
        }
    }
}

private extension AudioProcessingPipeline {

    func handleASRResult(
        _ response: BigModelQueryResponse,
        recordingItem: RecordingItem
    ) async throws {
        let utterances = response.result?.utterances ?? []
        // 1️⃣ 先批量转换成 TranscriptionItemRequest
        let items: [TranscriptionItemRequest] = utterances.map { item in
            return TranscriptionItemRequest(
                channel_id: Int16(item.additions?.channel_id ?? "0"),
                content: item.text,
                createTime: Int64(Date().timeIntervalSince1970),
                recordCreateTime: recordingItem.createTime,
                end_time: Double(item.end_time ?? 0),
                lang: " ",
                paragraph_id: 0,
                sentence_id: 0,
                speakerName: item.additions?.speaker,
                speakerType: Int16(item.additions?.speaker ?? "0"),
                start_time: Double(item.start_time ?? 0),
                words: ""
            )
        }
        // 2️⃣ 批量保存
        try TranscriptionItemStore.shared.addTranscriptionItems(items)
        recordingItem.transcriptionHtml = response.result?.text
        recordingItem.handleType = 3
        recordingItem.updateTime = Int64(Date().timeIntervalSince1970)
        try RecordingItemStore.shared.updateRecordingItem(recordingItem)
        UtitilTools.broadcast(handleStatus: 3, handleContent: "录音识别完成")
        try await handleAISummary(response.result?.text, recordingItem)
    }
}
private extension AudioProcessingPipeline {

    func handleAISummary(
        _ text: String?,
        _ recordingItem: RecordingItem
    ) async throws {

        guard let text, !text.isEmpty else { return }

        let summary = try await requestDoubaoAISummary(content: text)

        recordingItem.summaryTitle = summary.summaryTitle
        recordingItem.summaryContentJsonString = summary.summaryContent?.toJSONString()
        recordingItem.chapterSummaryJsonString = summary.chapterSummary?.toJSONString()
        recordingItem.todoJsonString = summary.todoList?.toJSONString()
        recordingItem.handleType = 4
        recordingItem.updateTime = Int64(Date().timeIntervalSince1970)
        UtitilTools.broadcast(handleStatus: 4, handleContent: "录音AI总结完成")
        try RecordingItemStore.shared.updateRecordingItem(recordingItem)
    }

    func fail(_ item: RecordingItem) {
        item.handleType = -1
        try? RecordingItemStore.shared.updateRecordingItem(item)
        UtitilTools.broadcast(handleStatus: 0, handleContent: "录音处理失败")
    }
}

