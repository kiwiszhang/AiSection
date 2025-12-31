//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//

import AVFoundation

final class UploadRecord: NSObject {
    static let shared = UploadRecord()

    func uploadFile(fileName:String,fileURL:URL,completion: @escaping (_ task:TOSTask<AnyObject>) -> Void){
        // 1. 初始化客户端
        let credential = TOSCredential.init(accessKey: AKeyID02 + AKeyID01, secretKey: SAKey)
        let tosEndpoint = TOSEndpoint(urlString: TOS_ENDPOINT, withRegion: TOS_REGION)
        let config = TOSClientConfiguration(endpoint: tosEndpoint, credential: credential)
        let client = TOSClient.init(configuration: config)

        // 2. 上传本地文件
        let put = TOSPutObjectFromFileInput()
        put.tosBucket = TOS_BUCKET
        put.tosKey = fileName
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

    func handleRecord(fileName:String,client:ByteDanceOpenSpeechClient,sourceLang: String = "zh_cn",targetLang: String = "en_us",completion: @escaping (_ queryData:QueryData) async -> Void){

        Task {
            do {
                let taskID = try await client.submitOfflineAudio(
                    fileURL: "https://aisection.tos-cn-beijing.volces.com/" + fileName,sourceLang:sourceLang,targetLang:targetLang
                )
                MyLog("https://aisection.tos-cn-beijing.volces.com/" + fileName)
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
