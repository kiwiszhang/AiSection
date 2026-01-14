//
//  File.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2026/1/7.
//


import Foundation

struct ChatCompletionResponse: Decodable {
    let choices: [Choice]
    struct Choice: Decodable {
        let message: Message
    }
    struct Message: Decodable {
        let role: String
        let content: String
    }
}
func requestDoubaoChat(text: String) async throws -> String {
    let url = URL(string: "https://ark.cn-beijing.volces.com/api/v3/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = 5 * 60
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(
        "Bearer e1cedb16-ddb9-4ac9-8ef7-5155bc686c3d",
        forHTTPHeaderField: "Authorization"
    )
    let body: [String: Any] = [
        "model": "doubao-seed-1-6-251015",
        "messages": [
//            ["role": "system", "content": "You are a helpful assistant."],
            ["role": "user", "content": text]
        ]
    ]

    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let http = response as? HTTPURLResponse,
          200..<300 ~= http.statusCode else {
        let text = String(data: data, encoding: .utf8)
        throw NSError(
            domain: "DoubaoError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: text ?? "Invalid response"]
        )
    }
    let result = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
    return result.choices.first?.message.content ?? ""
}
func requestDoubaoResponse(text: String) async throws -> DoubaoResponse {
    let url = URL(string: "https://ark.cn-beijing.volces.com/api/v3/responses")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = 5 * 60
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(
        "Bearer e1cedb16-ddb9-4ac9-8ef7-5155bc686c3d",
        forHTTPHeaderField: "Authorization"
    )
    let body: [String: Any] = [
        "model": "doubao-seed-1-6-251015",
        "input": text
    ]
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let http = response as? HTTPURLResponse,
          200..<300 ~= http.statusCode else {
        let text = String(data: data, encoding: .utf8)
        throw NSError(
            domain: "DoubaoResponsesError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: text ?? "Invalid response"]
        )
    }
    let decoded = try JSONDecoder().decode(DoubaoResponse.self, from: data)
//    let replyText = extractAssistantText(from: decoded)
    return decoded
}
func requestDoubaoResponseMutilChat(text: String,responseId:String) async throws -> DoubaoResponse {
    let url = URL(string: "https://ark.cn-beijing.volces.com/api/v3/responses")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = 60 * 5
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(
        "Bearer e1cedb16-ddb9-4ac9-8ef7-5155bc686c3d",
        forHTTPHeaderField: "Authorization"
    )
    let body: [String: Any] = [
        "model": "doubao-seed-1-6-251015",
        "previous_response_id":responseId,
        "input": text
    ]
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let http = response as? HTTPURLResponse,
          200..<300 ~= http.statusCode else {
        let text = String(data: data, encoding: .utf8)
        throw NSError(
            domain: "DoubaoResponsesError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: text ?? "Invalid response"]
        )
    }
    let decoded = try JSONDecoder().decode(DoubaoResponse.self, from: data)
//    let replyText = extractAssistantText(from: decoded)
    return decoded
}
func extractAssistantText(from response: DoubaoResponse) -> String {
    return response.output
        .first(where: { $0.type == "message" && $0.role == "assistant" })?
        .content?
        .first(where: { $0.type == "output_text" })?
        .text
        ?? ""
}
struct DoubaoResponse: Decodable {
    let id: String
    let output: [Output]
}
struct Output: Decodable {
    let id: String
    let type: String
    let role: String?
    let content: [Content]?
}
struct Content: Decodable {
    let type: String
    let text: String?
}
