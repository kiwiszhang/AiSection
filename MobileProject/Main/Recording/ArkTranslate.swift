//
//  File.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2026/1/7.
//


import Foundation

struct ArkResponse: Decodable {
    let id: String
    let model: String
    let status: String
    let output: [OutputMessage]
    let usage: Usage?

    struct OutputMessage: Decodable {
        let id: String
        let role: String
        let status: String
        let content: [Content]
    }

    struct Content: Decodable {
        let type: String
        let text: String?
    }

    struct Usage: Decodable {
        let input_tokens: Int
        let output_tokens: Int
        let total_tokens: Int
    }
}

extension ArkResponse {
    var translatedText: String? {
        output
            .first(where: { $0.status == "completed" })?
            .content
            .first(where: { $0.type == "output_text" })?
            .text
    }
}

enum TranslationError: Error {
    case emptyResult
}

func translateText(
    text: String,
    targetLanguage: String
) async throws -> String {

    let url = URL(string: "https://ark.cn-beijing.volces.com/api/v3/responses")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(
        "Bearer e1cedb16-ddb9-4ac9-8ef7-5155bc686c3d",
        forHTTPHeaderField: "Authorization"
    )
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: Any] = [
        "model": "doubao-seed-translation-250915",
        "input": [
            [
                "role": "user",
                "content": [
                    [
                        "type": "input_text",
                        "text": text,
                        "translation_options": [
                            "target_language": targetLanguage
                        ]
                    ]
                ]
            ]
        ]
    ]

    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, response) = try await URLSession.shared.data(for: request)

    if let httpResponse = response as? HTTPURLResponse,
       !(200...299).contains(httpResponse.statusCode) {
        throw URLError(.badServerResponse)
    }

    let responseData = try JSONDecoder().decode(ArkResponse.self, from: data)

    // ⭐️ 关键：安全取出翻译结果
    if let translatedText = responseData.translatedText {
        return translatedText
    } else {
        throw TranslationError.emptyResult
    }
}
