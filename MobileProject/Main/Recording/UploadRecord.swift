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

    func handleRecord(fileName:String,client:ByteDanceOpenSpeechClient,sourceLang: String = "zh_cn",targetLang: String = "en_us") async throws -> QueryData {

        let fileURL = "https://aisection.tos-cn-beijing.volces.com/" + fileName
        MyLog(fileURL)
        let taskID = try await client.submitOfflineAudio(
            fileURL: fileURL,
            sourceLang: sourceLang,
            targetLang: targetLang
        )
        MyLog("✅ TaskID:\(taskID)")
        let finished = try await client.waitUntilFinished(taskID: taskID)
        MyLog("📌 finished:\(finished)")
        return finished
    }
    
    
}
