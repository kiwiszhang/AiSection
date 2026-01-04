//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//

import Foundation

// MARK: - Client

public final class ByteDanceOpenSpeechClient {

    // MARK: Config

    public struct Config {
        public let appKey: String
        public let accessKey: String
        public let resourceId: String

        public init(appKey: String,
                    accessKey: String,
                    resourceId: String) {
            self.appKey = appKey
            self.accessKey = accessKey
            self.resourceId = resourceId
        }
    }

    private let config: Config
    private let session: URLSession

    public init(config: Config,
                session: URLSession = .shared) {
        self.config = config
        self.session = session
    }
}

// MARK: - Submit

public extension ByteDanceOpenSpeechClient {

    func submitOfflineAudio(
        fileURL: String,
        sourceLang: String = "zh_cn",
        targetLang: String = "en_us"
    ) async throws -> String {

        let body = SubmitRequest(
            Input: .init(
                Offline: .init(
                    FileURL: fileURL,
                    FileType: "audio"
                )
            ),
            Params: .init(
                AllActivate: true,
                SourceLang: sourceLang,
                AudioTranscriptionEnable: true,
                AudioTranscriptionParams: .init(
                    SpeakerIdentification: true,
                    NumberOfSpeaker: 0
                ),
                TranslationEnable: true,
                TranslationParams: .init(TargetLang: targetLang),
                InformationExtractionEnabled: true,
                InformationExtractionParams: .init(
                    Types: ["todo_list", "question_answer"]
                ),
                SummarizationEnabled: true,
                SummarizationParams: .init(Types: ["summary"]),
                ChapterEnabled: true
            )
        )

        let request = try makeSubmitRequest(body: body)
        let (data, _) = try await session.data(for: request)

        let submitData = try decodeWrapperResponse(SubmitData.self, from: data)
        return submitData.TaskID
    }
}

// MARK: - Polling（自动轮询）

public extension ByteDanceOpenSpeechClient {

    /// 自动轮询直到任务完成
    func waitUntilFinished(
        taskID: String,
        interval: TimeInterval = 10,
        timeout: TimeInterval = 300
    ) async throws -> QueryData {

        let start = Date()

        while true {
            if Date().timeIntervalSince(start) > 24 * 60 * 60 {
                throw OpenSpeechError.timeout
            }

            let data = try await queryTask(taskID: taskID)

            switch data.Status {
            case "success":
                return data
            case "failed":
                throw OpenSpeechError.server(
                    code: data.ErrCode,
                    message: data.ErrMessage
                )
            default:
                try await Task.sleep(
                    nanoseconds: UInt64(interval * 1_000_000_000)
                )
            }
        }
    }
}

// MARK: - Download & Parse Transcription

public extension ByteDanceOpenSpeechClient {

    // MARK: - 请求 AudioTranscriptionFile
    func fetchAudioTranscription(from url: String) async throws -> [AudioSentenceRaw] {
        guard let url = URL(string: url) else {
            throw OpenSpeechError.invalidResponse
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        // 🔍 建议保留，方便排查线上问题
        MyLog("📄 AudioTranscriptionFile raw:\n\(String(data: data, encoding: .utf8) ?? "")")
        let decoder = JSONDecoder()
        let sentences = try decoder.decode([AudioSentenceRaw].self, from: data)
        return sentences
    }
    // MARK: - 请求 AudioTranscriptionFileData
    func fetchAudioTranscriptionData(from url: String) async throws -> Data {
        guard let url = URL(string: url) else {
            throw OpenSpeechError.invalidResponse
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        // 🔍 建议保留，方便排查线上问题
        MyLog("📄 AudioTranscriptionFile raw:\n\(String(data: data, encoding: .utf8) ?? "")")
        return data
//        let decoder = JSONDecoder()
//        let sentences = try decoder.decode([AudioSentenceRaw].self, from: data)
//        return sentences
    }
    
    // MARK: - 请求 ChapterFile
    func fetchChapterFile(from url: String) async throws -> ChapterResponse {
        guard let url = URL(string: url) else {
            throw OpenSpeechError.invalidResponse
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        // 🔍 建议保留，方便排查线上问题
        MyLog("📄 ChapterFile raw:\n\(String(data: data, encoding: .utf8) ?? "")")
        let decoder = JSONDecoder()
        let sentences = try decoder.decode(ChapterResponse.self, from: data)
        return sentences
    }
    // MARK: - 请求 ChapterFileData
    func fetchChapterFileData(from url: String) async throws -> Data {
        guard let url = URL(string: url) else {
            throw OpenSpeechError.invalidResponse
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        // 🔍 建议保留，方便排查线上问题
        MyLog("📄 ChapterFile raw:\n\(String(data: data, encoding: .utf8) ?? "")")
        return data
//        let decoder = JSONDecoder()
//        let sentences = try decoder.decode(ChapterResponse.self, from: data)
//        return sentences
    }
    
    // MARK: - 请求 InformationExtractionFile
    func fetchInformationExtractionFile(from url: String) async throws -> InformationExtraction {
        guard let url = URL(string: url) else {
            throw OpenSpeechError.invalidResponse
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        // 🔍 建议保留，方便排查线上问题
        MyLog("📄 InformationExtraction raw:\n\(String(data: data, encoding: .utf8) ?? "")")
        let decoder = JSONDecoder()
        let sentences = try decoder.decode(InformationExtraction.self, from: data)
        return sentences
    }
    
    // MARK: - 请求 InformationExtractionFileData
    func fetchInformationExtractionFileData(from url: String) async throws -> Data {
        guard let url = URL(string: url) else {
            throw OpenSpeechError.invalidResponse
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        // 🔍 建议保留，方便排查线上问题
        MyLog("📄 InformationExtraction raw:\n\(String(data: data, encoding: .utf8) ?? "")")
        return data
//        let decoder = JSONDecoder()
//        let sentences = try decoder.decode(InformationExtraction.self, from: data)
//        return sentences
    }
    
    // MARK: - 请求 SummarizationFile
    func fetchSummarizationFile(from url: String) async throws -> Summarization {
        guard let url = URL(string: url) else {
            throw OpenSpeechError.invalidResponse
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        // 🔍 建议保留，方便排查线上问题
        MyLog("📄 SummarizationFile raw:\n\(String(data: data, encoding: .utf8) ?? "")")
        let decoder = JSONDecoder()
        let sentences = try decoder.decode(Summarization.self, from: data)
        return sentences
    }
    
    // MARK: - 请求 SummarizationFileData
    func fetchSummarizationFileData(from url: String) async throws -> Data {
        guard let url = URL(string: url) else {
            throw OpenSpeechError.invalidResponse
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        // 🔍 建议保留，方便排查线上问题
        MyLog("📄 SummarizationFile raw:\n\(String(data: data, encoding: .utf8) ?? "")")
        return data
//        let decoder = JSONDecoder()
//        let sentences = try decoder.decode(Summarization.self, from: data)
//        return sentences
    }
    
    // MARK: - 请求 TranslationFile
    func fetchTranslationFile(from url: String) async throws -> [TranslationRaw] {
        guard let url = URL(string: url) else {
            throw OpenSpeechError.invalidResponse
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        // 🔍 建议保留，方便排查线上问题
        MyLog("📄 TranslationRaw raw:\n\(String(data: data, encoding: .utf8) ?? "")")
        let decoder = JSONDecoder()
        let sentences = try decoder.decode([TranslationRaw].self, from: data)
        return sentences
    }
    // MARK: - 请求 TranslationFileData
    func fetchTranslationFileData(from url: String) async throws -> Data {
        guard let url = URL(string: url) else {
            throw OpenSpeechError.invalidResponse
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        // 🔍 建议保留，方便排查线上问题
        MyLog("📄 TranslationRaw raw:\n\(String(data: data, encoding: .utf8) ?? "")")
        return data
//        let decoder = JSONDecoder()
//        let sentences = try decoder.decode([TranslationRaw].self, from: data)
//        return sentences
    }

}

// MARK: - Query

public extension ByteDanceOpenSpeechClient {

    func queryTask(taskID: String) async throws -> QueryData {
        let request = try makeQueryRequest(taskID: taskID)
        let (data, _) = try await session.data(for: request)

        let response = try JSONDecoder().decode(QueryResponse.self, from: data)
        let dataNode = response.Data

        if dataNode.ErrCode != 0 {
            throw OpenSpeechError.server(
                code: dataNode.ErrCode,
                message: dataNode.ErrMessage
            )
        }

        return dataNode
    }
}

// MARK: - Request Builder

private extension ByteDanceOpenSpeechClient {

    func makeSubmitRequest(body: SubmitRequest) throws -> URLRequest {
        let url = URL(string: "https://openspeech.bytedance.com/api/v3/auc/lark/submit")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        applyHeaders(to: &request, includeSequence: true)
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    func makeQueryRequest(taskID: String) throws -> URLRequest {
        let url = URL(string: "https://openspeech.bytedance.com/api/v3/auc/lark/query")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        applyHeaders(to: &request, includeSequence: false)
        request.httpBody = try JSONEncoder().encode(
            QueryRequest(TaskID: taskID)
        )
        return request
    }

    func applyHeaders(
        to request: inout URLRequest,
        includeSequence: Bool
    ) {
        request.setValue(config.appKey, forHTTPHeaderField: "X-Api-App-Key")
        request.setValue(config.accessKey, forHTTPHeaderField: "X-Api-Access-Key")
        request.setValue(config.resourceId, forHTTPHeaderField: "X-Api-Resource-Id")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Api-Request-Id")
        if includeSequence {
            request.setValue("-1", forHTTPHeaderField: "X-Api-Sequence")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}

// MARK: - Decode Helper

private extension ByteDanceOpenSpeechClient {

    func decodeWrapperResponse<T: Codable>(
        _ type: T.Type,
        from data: Data
    ) throws -> T {

        let wrapper = try JSONDecoder().decode(
            OpenSpeechWrapperResponse<T>.self,
            from: data
        )

        if let code = wrapper.Code, code != 0 {
            throw OpenSpeechError.server(
                code: code,
                message: wrapper.Message ?? "Unknown error"
            )
        }

        guard let result = wrapper.Data else {
            throw OpenSpeechError.invalidResponse
        }

        return result
    }
}

// MARK: - Errors

public enum OpenSpeechError: Error, LocalizedError {
    case invalidResponse
    case timeout
    case server(code: Int, message: String)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .timeout:
            return "Task polling timed out"
        case .server(let code, let message):
            return "[\(code)] \(message)"
        }
    }
}

// MARK: - Models (Query)

private struct OpenSpeechWrapperResponse<T: Codable>: Codable {
    let Code: Int?
    let Message: String?
    let Data: T?
}

private struct SubmitData: Codable {
    let TaskID: String
}

private struct QueryRequest: Codable {
    let TaskID: String
}

private struct QueryResponse: Codable {
    let Data: QueryData
}

public struct QueryData: Codable {
    public let TaskID: String
    public let Status: String
    public let ErrCode: Int
    public let ErrMessage: String
    public let Result: QueryResult?
}

public struct QueryResult: Codable {
    public let AudioTranscriptionFile: String?
    public let ChapterFile: String?
    public let InformationExtractionFile: String?
    public let SummarizationFile: String?
    public let TranslationFile: String?
}

// MARK: - Audio Transcription Raw
public struct AudioSentenceRaw: Decodable {
    public let sentenceID: String
    public let paragraphID: String
    public let lang: String?
    public let content: String
    public let startTime: Double
    public let endTime: Double
    public let speaker: SpeakerRaw

    enum CodingKeys: String, CodingKey {
        case sentenceID = "sentence_id"
        case paragraphID = "paragraph_id"
        case lang
        case content
        case startTime = "start_time"
        case endTime = "end_time"
        case speaker
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        sentenceID = try c.decode(String.self, forKey: .sentenceID)
        paragraphID = try c.decode(String.self, forKey: .paragraphID)
        lang = try? c.decode(String.self, forKey: .lang)
        content = try c.decode(String.self, forKey: .content)
        speaker = try c.decode(SpeakerRaw.self, forKey: .speaker)

        func decodeTime(_ key: CodingKeys) throws -> Double {
            if let v = try? c.decode(Double.self, forKey: key) {
                return v
            }
            if let s = try? c.decode(String.self, forKey: key) {
                return Double(s) ?? 0
            }
            return 0
        }

        startTime = try decodeTime(.startTime)
        endTime = try decodeTime(.endTime)
    }
}

public struct SpeakerRaw: Decodable {
    public let id: Int
    public let name: String?
    public let type: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        // id: String or Int
        if let intID = try? c.decode(Int.self, forKey: .id) {
            id = intID
        } else {
            let strID = try c.decode(String.self, forKey: .id)
            id = Int(strID) ?? 0
        }

        name = try? c.decode(String.self, forKey: .name)
        type = try? c.decode(Int.self, forKey: .type)
    }
}


// MARK: - ChapterFile（章节总结）
public struct ChapterResponse: Decodable {
    let chapterSummary: [Chapter]

    enum CodingKeys: String, CodingKey {
        case chapterSummary = "chapter_summary"
    }
}

struct Chapter: Decodable {
    let startTime: Double
    let endTime: Double
    let title: String
    let summary: String

    enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case endTime = "end_time"
        case title
        case summary
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        func decodeTime(_ key: CodingKeys) -> Double {
            if let v = try? c.decode(Double.self, forKey: key) {
                return v
            }
            if let s = try? c.decode(String.self, forKey: key) {
                return Double(s) ?? 0
            }
            return 0
        }

        startTime = decodeTime(.startTime)
        endTime = decodeTime(.endTime)
        title = try c.decode(String.self, forKey: .title)
        summary = try c.decode(String.self, forKey: .summary)
    }
}

// MARK: - InformationExtractionFile（结构化信息）
public struct InformationExtraction: Decodable {
    public let questionAnswer: [QuestionAnswer]
    public let todoList: [TodoItem]

    enum CodingKeys: String, CodingKey {
        case questionAnswer = "question_answer"
        case todoList = "todo_list"
    }
}

public struct QuestionAnswer: Decodable {
    public let question: String?
    public let answer: String?
    public let questionTime: String?
    public let questionType: String?
    public let sentenceID: String?

    enum CodingKeys: String, CodingKey {
        case question
        case answer
        case questionTime = "question_time"
        case questionType = "question_type"
        case sentenceID = "sentence_id"
    }
}


public struct TodoItem: Decodable {
    public let content: String?
    public let executionDDL: String?
    public let executionTime: [String]?
    public let executor: [String]?
    public let sentenceID: [String]?
    public let startTime: Double?
    public let todoIdx: Int?
    
    public let polishedResult: PolishedTodo?

    enum CodingKeys: String, CodingKey {
        case content
        case executionDDL = "execution_ddl"
        case executionTime = "execution_time"
        case executor
        case sentenceID = "sentence_id"
        case startTime = "start_time"
        case todoIdx = "todo_idx"
        case polishedResult = "polished_res"
    }
}

public struct PolishedTodo: Decodable {
    public let content: String
    public let executionDDL: String?
    public let executors: [String]

    enum CodingKeys: String, CodingKey {
        case content
        case executionDDL = "execution_ddl"
        case executors = "executor"
    }
}


// MARK: - SummarizationFile（全文总结）
public struct Summarization: Decodable {
    let title: String
    let paragraph: String
}

// MARK: - TranslationFile（翻译）
public struct TranslationRaw: Decodable {
    public let sentenceID: String
    public let paragraphID: String?
    public let sourceLang: String
    public let targetLang: String
    public let content: String
    public let translationContent: String
    public let startTime: Double
    public let endTime: Double
    public let speaker: SpeakerRaw

    enum CodingKeys: String, CodingKey {
        case sentenceID = "sentence_id"
        case paragraphID = "paragraph_id"
        case sourceLang = "source_lang"
        case targetLang = "target_lang"
        case content
        case translationContent = "translation_content"
        case startTime = "start_time"
        case endTime = "end_time"
        case speaker
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        sentenceID = try c.decode(String.self, forKey: .sentenceID)
        paragraphID = try? c.decode(String.self, forKey: .paragraphID)
        sourceLang = try c.decode(String.self, forKey: .sourceLang)
        targetLang = try c.decode(String.self, forKey: .targetLang)
        content = try c.decode(String.self, forKey: .content)
        translationContent = try c.decode(String.self, forKey: .translationContent)
        speaker = try c.decode(SpeakerRaw.self, forKey: .speaker)

        func decodeTime(_ key: CodingKeys) -> Double {
            if let v = try? c.decode(Double.self, forKey: key) {
                return v
            }
            if let s = try? c.decode(String.self, forKey: key) {
                return Double(s) ?? 0
            }
            return 0
        }

        startTime = decodeTime(.startTime)
        endTime = decodeTime(.endTime)
    }
}

// MARK: - Submit Body

private struct SubmitRequest: Codable {

    struct Input: Codable {
        struct Offline: Codable {
            let FileURL: String
            let FileType: String
        }
        let Offline: Offline
    }

    struct Params: Codable {
        let AllActivate: Bool
        let SourceLang: String
        let AudioTranscriptionEnable: Bool

        struct AudioTranscriptionParams: Codable {
            let SpeakerIdentification: Bool
            let NumberOfSpeaker: Int
        }
        let AudioTranscriptionParams: AudioTranscriptionParams

        let TranslationEnable: Bool
        struct TranslationParams: Codable {
            let TargetLang: String
        }
        let TranslationParams: TranslationParams

        let InformationExtractionEnabled: Bool
        struct InformationExtractionParams: Codable {
            let Types: [String]
        }
        let InformationExtractionParams: InformationExtractionParams

        let SummarizationEnabled: Bool
        struct SummarizationParams: Codable {
            let Types: [String]
        }
        let SummarizationParams: SummarizationParams

        let ChapterEnabled: Bool
    }

    let Input: Input
    let Params: Params
}
