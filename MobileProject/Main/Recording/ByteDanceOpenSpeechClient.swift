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

    // MARK: Submit Task

    public func submitOfflineAudio(
        fileURL: String,
        sourceLang: String = "zh_cn",
        targetLang: String = "zh_cn",
        enableSpeakerIdentification: Bool = true,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
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
                    SpeakerIdentification: enableSpeakerIdentification,
                    NumberOfSpeaker: 0
                ),
                TranslationEnable: false,
                TranslationParams: .init(
                    TargetLang: targetLang
                ),
                InformationExtractionEnabled: true,
                InformationExtractionParams: .init(
                    Types: ["todo_list", "question_answer"]
                ),
                SummarizationEnabled: true,
                SummarizationParams: .init(
                    Types: ["summary"]
                ),
                ChapterEnabled: true
            )
        )

        do {
            let request = try makeSubmitRequest(body: body)
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NSError(
                        domain: "OpenSpeech",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Empty response"]
                    )))
                    return
                }
                completion(.success(data))
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
}

// MARK: - Request Builder

private extension ByteDanceOpenSpeechClient {

    func makeSubmitRequest(body: SubmitRequest) throws -> URLRequest {
        let url = URL(string: "https://openspeech.bytedance.com/api/v3/auc/lark/submit")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue(config.appKey, forHTTPHeaderField: "X-Api-App-Key")
        request.setValue(config.accessKey, forHTTPHeaderField: "X-Api-Access-Key")
        request.setValue(config.resourceId, forHTTPHeaderField: "X-Api-Resource-Id")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Api-Request-Id")
        request.setValue("-1", forHTTPHeaderField: "X-Api-Sequence")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        return request
    }
}

// MARK: - Models

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

// MARK: - Response
struct SubmitResponse: Codable {
    struct DataContainer: Codable {
        let TaskID: String?
    }
    let Data: DataContainer?
}
