//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//

import AVFoundation

final class UploadRecord: NSObject {
    static let shared = UploadRecord()

    func uploadFile(fileName:String,completion: @escaping (_ task:TOSTask<AnyObject>) -> Void){
        let recordURL = RecorderManager.shared.recordURL
        MyLog("上传文件：\(String(describing: recordURL))")
        guard let lastFile = recordURL,let fileURL = URL(string: lastFile.absoluteString) else {
            MyLog("上传失败：无可用文件或路径错误")
            return
        }
        
        var tosKey = ""
        if !kkStringIsEmpty(fileURL.path) {
            let result = fileURL.path.components(separatedBy: "/Documents/")
            if result.count == 2 {
                tosKey = result[1]
            }
        }
        
        // 1. 初始化客户端
        let credential = TOSCredential.init(accessKey: AKeyID02 + AKeyID01, secretKey: SAKey)
        let tosEndpoint = TOSEndpoint(urlString: TOS_ENDPOINT, withRegion: TOS_REGION)
        let config = TOSClientConfiguration(endpoint: tosEndpoint, credential: credential)
        let client = TOSClient.init(configuration: config)

        // 2. 上传本地文件
        let put = TOSPutObjectFromFileInput()
        put.tosBucket = TOS_BUCKET
        put.tosKey = tosKey
        MyLog(fileURL.path)
        put.tosFilePath = fileURL.path
        let task = client.putObject(fromFile: put)

        task.continueWith { t in
            completion(t)
            return nil
        }
    }
    
    
}

final class SubmitAndQueryHandle: NSObject {
    static let shared = SubmitAndQueryHandle()

    func handleRecord(fileName:String,client:ByteDanceOpenSpeechClient,completion: @escaping (_ queryData:QueryData) async -> Void){

        Task {
            do {
                let taskID = try await client.submitOfflineAudio(
                    fileURL: "https://aisection.tos-cn-beijing.volces.com/" + fileName
                )
                MyLog("✅ TaskID:\(taskID)")

                let finished = try await client.waitUntilFinished(taskID: taskID)
                MyLog("📌 finished:\(finished)")
                await completion(finished)
//                if let url = finished.Result?.AudioTranscriptionFile {
//                    let listData = try await client.fetchAudioTranscription(from: url)
//                    listData.forEach { item in
//                        MyLog("🧑 Speaker: \(item.speaker.name ?? "Speaker")")
//                        MyLog("content: \(item.content)")
//                    }
//                }
//
//                if let url = finished.Result?.ChapterFile {
//                    let listData = try await client.fetchChapterFile(from: url)
//                    MyLog(listData.chapterSummary)
//                }
//
//                if let url = finished.Result?.InformationExtractionFile {
//                    let listData = try await client.fetchInformationExtractionFile(from: url)
//                    MyLog(listData.todoList)
//                }
//
//                if let url = finished.Result?.SummarizationFile {
//                    let itemData = try await client.fetchSummarizationFile(from: url)
//                    MyLog(itemData.title)
//                    MyLog(itemData.paragraph)
//                }
//
//                if let url = finished.Result?.TranslationFile {
//                    let listData = try await client.fetchTranslationFile(from: url)
//                    MyLog(listData)
//                }

            } catch {
                MyLog("❌ Error: \(error.localizedDescription)")
            }
        }
    }
    
    
}
