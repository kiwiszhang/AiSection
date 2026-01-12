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


struct ChatRequest: Encodable {
    let model: String
    let messages: [Message]

    struct Message: Encodable {
        let role: String
        let content: String
    }
}

struct CompletionResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let role: String
        let content: String
    }
}

struct ContentWrapper: Decodable {
    let content: String
}

func requestDoubaoContent(html:String,targetLang:String) async throws -> String {
    
    let url = URL(string: "https://ark.cn-beijing.volces.com/api/v3/chat/completions")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer 35c11675-66e0-4d52-8f91-09c1385de0a4",
                     forHTTPHeaderField: "Authorization")
    
    let body: [String: Any] = [
        "model": "doubao-1-5-pro-32k-250115",
        "messages": [
            ["role": "system", "content": "你是人工智能助手."],
            ["role": "user", "content": "\(html) 将这个html里面的内容翻译为: \(targetLang)，翻译完成后html标签的结构和样式不改变，返回的结果为{\"content\":\"XXXX\"}这种json格式"]
        ]
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    // 🔍 调试用（可删）
    if let json = String(data: data, encoding: .utf8) {
        print("Response JSON:", json)
    }
    
    // ✅ 解析 {"content":"XXXX"}
    let response = try JSONDecoder().decode(CompletionResponse.self, from: data)
    // ✅ 安全取值并返回 content
    guard let content = response.choices.first?.message.content else {
        throw NSError(domain: "DoubaoError",
                      code: -1,
                      userInfo: [NSLocalizedDescriptionKey: "content 不存在"])
    }
    
    return content
}

func extractHTML(from jsonString: String) throws -> String {
    guard let data = jsonString.data(using: .utf8) else {
        throw NSError(domain: "ParseError", code: -1)
    }

    let wrapper = try JSONDecoder().decode(ContentWrapper.self, from: data)
    return wrapper.content
}

