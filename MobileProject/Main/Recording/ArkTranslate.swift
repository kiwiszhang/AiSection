//
//  File.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2026/1/7.
//


import Foundation


struct SummaryResult: Codable {
    let todoList: [String]?
    let summaryTitle: String?
    let summaryContent: [String]?
    let chapterSummary: [ChapterSummary]?
}
struct ChapterSummary: Codable {
    let title: String
    let content: [String]
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
func requestDoubaoContent(html:String,targetLang:String) async throws -> String {
    let url = URL(string: "https://ark.cn-beijing.volces.com/api/v3/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = 5 * 60
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
    let response = try JSONDecoder().decode(CompletionResponse.self, from: data)
    guard let content = response.choices.first?.message.content else {
        throw NSError(domain: "DoubaoError",
                      code: -1,
                      userInfo: [NSLocalizedDescriptionKey: "content 不存在"])
    }
    return content
}

func requestDoubaoAISummary(content:String) async throws -> SummaryResult {
    let url = URL(string: "https://ark.cn-beijing.volces.com/api/v3/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = 5 * 60
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer 35c11675-66e0-4d52-8f91-09c1385de0a4",
                     forHTTPHeaderField: "Authorization")
    let body: [String: Any] = [
        "model": "doubao-1-5-pro-32k-250115",
        "messages": [
            ["role": "system", "content": "你是人工智能助手."],
            ["role": "user", "content": "\(content) \n 将前面这一段录音转文本的内容进行处理需求点如下： 1. 生成代办事项进行列表处理； 2.生成总结标题和内容，内容进行列表处理； 3.生成章节总结，有标题和列表内容,以上所有生成内容如果没有这个数据就返回该字段为空 上面的每项都单独包裹成一个键值对，如果是列表的就在键值对里面放上数组,总体结构：{ \"todoList\": [ \"XXX\" ], \"summaryTitle\": \"XXX\", \"summaryContent\": [ \"XXX\" ], \"chapterSummary\": [ { \"title\": \"XXX\", \"content\": [ \"XXX\" ] } ] }"]
        ]
    ]
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    let (data, _) = try await URLSession.shared.data(for: request)
    // 🔍 调试用（可删）
    if let json = String(data: data, encoding: .utf8) {
        print("Response JSON:", json)
    }
    let response = try JSONDecoder().decode(CompletionResponse.self, from: data)
    guard let content = response.choices.first?.message.content else {
        throw NSError(domain: "DoubaoError",
                      code: -1,
                      userInfo: [NSLocalizedDescriptionKey: "content 不存在"])
    }
    let contentData = content.data(using: .utf8)!
    let decoder = JSONDecoder()
    let result = try decoder.decode(SummaryResult.self, from: contentData)
    return result
}

extension Encodable {
    func toJSONString(pretty: Bool = false) -> String? {
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = .prettyPrinted
        }
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
extension String {
    func toModel<T: Decodable>(_ type: T.Type) -> T? {
        guard let data = self.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
extension Array where Element == String {
    func toJSONString() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    static func fromJSONString(_ json: String) -> [String]? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([String].self, from: data)
    }
}
