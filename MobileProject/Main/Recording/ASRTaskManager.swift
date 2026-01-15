//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//

import Foundation

final class ASRTaskManager {
    private let appID: String
    private let token: String
    init(appID: String, token: String) {
        self.appID = appID
        self.token = token
    }
    // MARK: - Public
    func transcribe(
        audioURL: String,
        format: String,
        language: String?,
        timeout: TimeInterval = 60 * 60 * 24
    ) async throws -> BigModelQueryResponse {
        let taskId = UUID().uuidString
        let (submittedTaskId, logId) = try await submitTask(
            taskId: taskId,
            audioURL: audioURL,
            format: format,
            language: language
        )
        UtitilTools.broadcast(handleStatus: 3, handleContent: "录音文件上传成功")
        guard let logId else {
            throw ASRError.invalidSubmit
        }
        return try await pollResult(
            taskId: submittedTaskId,
            xTtLogid: logId,
            timeout: timeout
        )
    }
}

private extension ASRTaskManager {
    func submitTask(
        taskId: String,
        audioURL: String,
        format: String,
        language: String?
    ) async throws -> (String, String?) {
        let audio: [String: Any?] = [
            "url": audioURL,
            "format": format,
            "language": language
        ]
        let requestBody: [String: Any] = [
            "user": ["uid": "ios_user"],
            "audio": audio.compactMapValues { $0 },
            "request": [
                "model_name": "bigmodel",
                "enable_punc": true,
                "enable_itn": true,
                "enable_ddc": true,
                "enable_channel_split": true,
                "enable_speaker_info": true,
                "corpus": [
                    "context": "",
                    "correct_table_name": ""
                ]
            ]
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: requestBody)
        var request = URLRequest(
            url: URL(string: "https://openspeech.bytedance.com/api/v3/auc/bigmodel/submit")!
        )
        request.httpMethod = "POST"
        request.timeoutInterval = 5 * 60
        request.httpBody = bodyData
        setCommonHeaders(&request, taskId: taskId)
        request.setValue("-1", forHTTPHeaderField: "X-Api-Sequence")
        let (data, response) = try await URLSession.shared.data(for: request)
        let http = response as! HTTPURLResponse
        logResponse("Submit", http: http, data: data)
        guard http.value(forHTTPHeaderField: "X-Api-Status-Code") == "20000000" else {
            throw ASRError.submitFailed
        }
        return (taskId, http.value(forHTTPHeaderField: "X-Tt-Logid"))
    }
}

private extension ASRTaskManager {
    func pollResult(
        taskId: String,
        xTtLogid: String,
        timeout: TimeInterval
    ) async throws -> BigModelQueryResponse {
        let start = Date()
        var delay: UInt64 = 1_500_000_000   // 1.5s → 3s → 5s
        while true {
            if Date().timeIntervalSince(start) > timeout {
                throw ASRError.timeout
            }
            print("🔁 Polling ASR...")
            do {
                let state = try await queryOnce(
                    taskId: taskId,
                    xTtLogid: xTtLogid
                )
                switch state {
                case .processing:
                    print("⏳ Processing, next in \(delay / 1_000_000_000)s")
                    try await Task.sleep(nanoseconds: delay)
                    delay = min(delay * 2, 12_000_000_000)
                case .finished(let response):
                    print("✅ ASR Finished")
                    return response
                }
            } catch {
                print("❌ Poll error:", error)
                throw error
            }
        }
    }
}

private extension ASRTaskManager {
    enum QueryState {
        case processing
        case finished(BigModelQueryResponse)
    }
    func queryOnce(
        taskId: String,
        xTtLogid: String
    ) async throws -> QueryState {
        var request = URLRequest(
            url: URL(string: "https://openspeech.bytedance.com/api/v3/auc/bigmodel/query")!
        )
        request.httpMethod = "POST"
        request.timeoutInterval = 5 * 60
        request.httpBody = "{}".data(using: .utf8)
        setCommonHeaders(&request, taskId: taskId)
        request.setValue(xTtLogid, forHTTPHeaderField: "X-Tt-Logid")
        let (data, response) = try await URLSession.shared.data(for: request)
        let http = response as! HTTPURLResponse
        let status = http.value(forHTTPHeaderField: "X-Api-Status-Code") ?? ""
        logResponse("Query", http: http, data: data)
        if status == "20000001" {
            return .processing
        }
        if status != "20000000" {
            throw ASRError.queryFailed
        }
        let decoder = JSONDecoder()
        let result = try decoder.decode(BigModelQueryResponse.self, from: data)
        return .finished(result)
    }
}
struct BigModelQueryResponse: Codable {
    let audio_info: AudioInfo?
    let result: ResultData?
}
struct AudioInfo: Codable {
    let duration: Int?
}
struct ResultData: Codable {
    let text: String?
    let additions: Additions?
    let utterances: [Utterance]?
}
struct Additions: Codable {
    let duration: String?
}
struct Utterance: Codable {
    let start_time: Int?
    let end_time: Int?
    let text: String?
    let additions: UtteranceAdditions?
    let words: [Word]?
}

struct UtteranceAdditions: Codable {
    let channel_id: String?
    let speaker: String?
}

struct Word: Codable {
    let text: String?
    let start_time: Int?
    let end_time: Int?
    let confidence: Double?
}

private extension ASRTaskManager {

    func setCommonHeaders(_ request: inout URLRequest, taskId: String) {
        request.setValue(appID, forHTTPHeaderField: "X-Api-App-Key")
        request.setValue(token, forHTTPHeaderField: "X-Api-Access-Key")
        request.setValue(XApiResourceId, forHTTPHeaderField: "X-Api-Resource-Id")
        request.setValue(taskId, forHTTPHeaderField: "X-Api-Request-Id")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    func logResponse(_ tag: String, http: HTTPURLResponse, data: Data) {
        print("——— \(tag) Response ———")
        print("Status:", http.value(forHTTPHeaderField: "X-Api-Status-Code") ?? "")
        print("Message:", http.value(forHTTPHeaderField: "X-Api-Message") ?? "")
        print("LogId:", http.value(forHTTPHeaderField: "X-Tt-Logid") ?? "")
        if let body = String(data: data, encoding: .utf8) {
            print("Body:", body)
        }
        print("———————————————")
    }
}

enum ASRError: LocalizedError {
    case submitFailed
    case queryFailed
    case timeout
    case invalidSubmit
    var errorDescription: String? {
        switch self {
        case .submitFailed: return "ASR 提交失败"
        case .queryFailed: return "ASR 查询失败"
        case .timeout: return "ASR 超时"
        case .invalidSubmit: return "无效的提交响应"
        }
    }
}
