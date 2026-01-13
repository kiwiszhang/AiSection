//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//

import Foundation

struct BigModelSubmitRequest: Codable {
    
    struct Audio: Codable {
        let format: String
        let url: String
        let language: String?   // ✅ 可选
    }

    struct Request: Codable {
        let model_name: String
        let enable_itn: Bool
    }

    let audio: Audio
    let request: Request
}

func submitBigModelTask(
    appKey: String,
    accessKey: String,
    resourceId: String = "volc.seedasr.auc",
    requestId: String,
    audioURL: String
) async throws -> Data {

    let url = URL(string: "https://openspeech.bytedance.com/api/v3/auc/bigmodel/submit")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // Header
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(appKey, forHTTPHeaderField: "X-Api-App-Key")
    request.setValue(accessKey, forHTTPHeaderField: "X-Api-Access-Key")
    request.setValue(resourceId, forHTTPHeaderField: "X-Api-Resource-Id")
    request.setValue(requestId, forHTTPHeaderField: "X-Api-Request-Id")
    request.setValue("-1", forHTTPHeaderField: "X-Api-Sequence")

    let parts = audioURL.split(separator: ".")
    // Body
    let format = String(parts.last ?? "m4a")
//    let audio = BigModelSubmitRequest.Audio(
//        format: format,
//        url: audioURL,
//        language: kkStringIsEmpty(UserDefaultsTools.recordLangugasSelected)
//            ? nil
//            : UserDefaultsTools.recordLangugasSelected
//    )
//
//    let body = BigModelSubmitRequest(
//        audio:audio,
//        request: .init(
//            model_name: "bigmodel",
//            enable_itn: true
//        )
//    )
//    
//    
//    request.httpBody = try JSONEncoder().encode(body)

    var audioDict: [String: Any] = [
        "format": format,
        "url": audioURL,
    ]

    if !kkStringIsEmpty(UserDefaultsTools.recordLangugasSelected) {
        audioDict["language"] = UserDefaultsTools.recordLangugasSelected
    }

    let json: [String: Any] = [
        "audio": audioDict,
        "request": [
            "model_name": "bigmodel",
            "enable_itn": true
        ]
    ]

    let dataBody = try JSONSerialization.data(withJSONObject: json)
    request.httpBody = dataBody

    
    
    let (data, response) = try await URLSession.shared.data(for: request)

    if let httpResponse = response as? HTTPURLResponse {
        print("Status Code:", httpResponse.statusCode)
    }

    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        print("Response JSON:", jsonObject)
    } catch {
        print("❌ JSON 解析失败:", error)
    }

    return data
}

func queryBigModelResult(
    appKey: String,
    accessKey: String,
    resourceId: String,
    taskId: String
) async throws -> Data {
    
    let url = URL(string: "https://openspeech.bytedance.com/api/v3/auc/bigmodel/query")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // Header
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(appKey, forHTTPHeaderField: "X-Api-App-Key")
    request.setValue(accessKey, forHTTPHeaderField: "X-Api-Access-Key")
    request.setValue(resourceId, forHTTPHeaderField: "X-Api-Resource-Id")
    request.setValue(taskId, forHTTPHeaderField: "X-Api-Request-Id")
    
    // body 是空 JSON
    request.httpBody = Data("{}".utf8)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    if let httpResponse = response as? HTTPURLResponse {
        print("HTTP Status:", httpResponse.statusCode)
    }
    
    // 🔥 调试用：打印返回内容
    if let jsonString = String(data: data, encoding: .utf8) {
        print("Query Response:\n", jsonString)
    }
    
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        print("Response JSON:", jsonObject)
    } catch {
        print("❌ JSON 解析失败:", error)
    }
    return data
}

//func submitTaskTest(
//    fileURL: String,
//    appID: String,
//    token: String,
//    taskId: String
//) async throws -> (taskId: String, logId: String?) {
//
////    let taskId = UUID().uuidString
//    print("Submit task id: \(taskId)")
//
//    // user
//    let user: [String: Any] = [
//        "uid": "388808087183456"
//    ]
//
//    // audio
//    let audio: [String: Any] = [
//        "url": fileURL,
//        "format":"mp3",
//        "language": UserDefaultsTools.recordLangugasSelected
////        "language": ""
//    ]
//
//    // corpus
//    let corpus: [String: Any] = [
//        "correct_table_name": "",
//        "context": ""
//    ]
//
//    // request
//    let innerRequest: [String: Any] = [
//        "model_name": "bigmodel",
//        "enable_channel_split": true,
//        "enable_ddc": true,
//        "enable_speaker_info": true,
//        "enable_punc": true,
//        "enable_itn": true,
//        "corpus": corpus
//    ]
//
//    // main request
//    let mainRequest: [String: Any] = [
//        "user": user,
//        "audio": audio,
//        "request": innerRequest
//    ]
//
//    // JSON
//    let jsonData = try JSONSerialization.data(
//        withJSONObject: mainRequest,
//        options: [.prettyPrinted]
//    )
//
//    if let jsonString = String(data: jsonData, encoding: .utf8) {
//        print("Submit mainRequest:\n\(jsonString)\n")
//    }
//
//    // URLRequest
//    var request = URLRequest(
//        url: URL(string: "https://openspeech.bytedance.com/api/v3/auc/bigmodel/submit")!
//    )
//    request.httpMethod = "POST"
//    request.httpBody = jsonData
//
//    // Headers
//    request.setValue(appID, forHTTPHeaderField: "X-Api-App-Key")
//    request.setValue(token, forHTTPHeaderField: "X-Api-Access-Key")
//    request.setValue("volc.bigasr.auc", forHTTPHeaderField: "X-Api-Resource-Id")
//    request.setValue(taskId, forHTTPHeaderField: "X-Api-Request-Id")
//    request.setValue("-1", forHTTPHeaderField: "X-Api-Sequence")
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//    // Request
//    let (data, response) = try await URLSession.shared.data(for: request)
//
//    guard let httpResponse = response as? HTTPURLResponse else {
//        throw NSError(domain: "InvalidResponse", code: -1)
//    }
//
//    let responseBody = String(data: data, encoding: .utf8) ?? ""
//    print("Response Body: \(responseBody)")
//
//    let statusCode = httpResponse.value(forHTTPHeaderField: "X-Api-Status-Code")
//    let message = httpResponse.value(forHTTPHeaderField: "X-Api-Message")
//    let logId = httpResponse.value(forHTTPHeaderField: "X-Tt-Logid")
//
//    if statusCode == "20000000" {
//        print("Submit task success")
//        print("X-Api-Status-Code:", statusCode ?? "")
//        print("X-Api-Message:", message ?? "")
//        print("X-Tt-Logid:", logId ?? "")
//        return (taskId, logId)
//    } else {
//        print("Submit task failed, headers:", httpResponse.allHeaderFields)
//        throw NSError(domain: "SubmitFailed", code: -1)
//    }
//}
//
//
//func queryTaskTest(
//    taskId: String,
//    xTtLogid: String,
//    appID: String,
//    token: String
//) async throws -> (BigModelQueryResponse) {
//
//    // body: {}
//    let bodyData = "{}".data(using: .utf8)!
//
//    var request = URLRequest(
//        url: URL(string: "https://openspeech.bytedance.com/api/v3/auc/bigmodel/query")!
//    )
//    request.httpMethod = "POST"
//    request.httpBody = bodyData
//
//    // Headers（与 Java 完全一致）
//    request.setValue(appID, forHTTPHeaderField: "X-Api-App-Key")
//    request.setValue(token, forHTTPHeaderField: "X-Api-Access-Key")
//    request.setValue("volc.bigasr.auc", forHTTPHeaderField: "X-Api-Resource-Id")
//    request.setValue(taskId, forHTTPHeaderField: "X-Api-Request-Id")
//    request.setValue(xTtLogid, forHTTPHeaderField: "X-Tt-Logid")
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//    let (data, response) = try await URLSession.shared.data(for: request)
//
//    guard let httpResponse = response as? HTTPURLResponse else {
//        throw NSError(domain: "InvalidResponse", code: -1)
//    }
//
//    // 打印 Header（等价 Java）
//    if let statusCode = httpResponse.value(forHTTPHeaderField: "X-Api-Status-Code") {
//        print("Query task response header X-Api-Status-Code:", statusCode)
//        print("Query task response header X-Api-Message:",
//              httpResponse.value(forHTTPHeaderField: "X-Api-Message") ?? "")
//        print("Query task response header X-Tt-Logid:",
//              httpResponse.value(forHTTPHeaderField: "X-Tt-Logid") ?? "", "\n")
//    } else {
//        print("Query task failed and the response headers are:",
//              httpResponse.allHeaderFields)
//        throw NSError(domain: "QueryFailed", code: -1)
//    }
//    // 打印 Body（方便调试）
//    if let bodyString = String(data: data, encoding: .utf8) {
//        print("Query response body:\n\(bodyString)")
//    }
//    let decoder = JSONDecoder()
//    let resultResponse = try decoder.decode(BigModelQueryResponse.self,from: data)
//    return resultResponse
//}
//
//struct BigModelQueryResponse: Codable {
//    let audio_info: AudioInfo?
//    let result: ResultData?
//}
//struct AudioInfo: Codable {
//    let duration: Int
//}
//
//struct ResultData: Codable {
//    let additions: Additions?
//    let text: String?
//    let utterances: [Utterance]?
//}
//
//struct Additions: Codable {
//    let duration: String?
//}
//
//struct Utterance: Codable {
//    let additions: UtteranceAdditions?
//    let start_time: Int
//    let end_time: Int
//    let text: String
//    let words: [Word]?
//}
//
//struct UtteranceAdditions: Codable {
//    let channel_id: String?
//    let speaker: String?
//}
//
//struct Word: Codable {
//    let text: String
//    let start_time: Int
//    let end_time: Int
//    let confidence: Double
//}
