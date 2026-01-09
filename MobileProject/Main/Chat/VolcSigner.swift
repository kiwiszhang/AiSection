import CryptoKit
import Foundation

private let VolcanoEngineAK = "AKLTYTVjNmUyMzJmMTRjNGQ2NWFiMjZkMjg1OWUyNDk0Yjc"
private let VolcanoEngineSK = "TWpWa05tRTFNV1JoTkRZd05HUTJaR0UwTXpKaE5qa3dPVE5qWlRjNE1tVQ=="

// MARK: - 辅助枚举（Content-Type 类型）
enum RequestContentType: String {
    case json = "application/json"
    case formUrlEncoded = "application/x-www-form-urlencoded"
}

// MARK: - 签名核心类
class VolcSigner {
    // URL编码允许的字符集（RFC3986 规范，文档要求）
    private static let urlAllowedCharacters: Set<UInt8> = {
        var set = Set<UInt8>()
        (97 ... 122).forEach { set.insert(UInt8($0)) }
        (65 ... 90).forEach { set.insert(UInt8($0)) }
        (48 ... 57).forEach { set.insert(UInt8($0)) }
        [45, 95, 46, 126].forEach { set.insert(UInt8($0)) }
        return set
    }()

    private static let hexEncodeTable = "0123456789abcdef" // 小写十六进制（文档要求）
    private static let utf8 = String.Encoding.utf8
    private static let getFixedSha256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" // GET固定哈希

    // 签名必要参数（文档示例配置）
    private let region: String
    private let service: String
    private let schema: String
    private let host: String
    private let path: String
    private let ak: String
    private let sk: String

    // 初始化
    init(
        region: String,
        service: String,
        schema: String,
        host: String,
        path: String,
        ak: String = VolcanoEngineAK,
        sk: String = VolcanoEngineSK
    ) {
        self.region = region
        self.service = service
        self.schema = schema
        self.host = host
        self.path = path
        self.ak = ak
        self.sk = sk
    }
}

// MARK: - URL编码（RFC3986 规范，文档要求）
extension VolcSigner {
    private func urlEncode(_ source: String?) -> String {
        guard let source = source else { return "" }
        guard let data = source.data(using: Self.utf8) else { return source }

        var result = ""
        let bytes = [UInt8](data)

        for byte in bytes {
            if Self.urlAllowedCharacters.contains(byte) {
                result.append(Character(UnicodeScalar(byte)))
            } else if byte == 32 {
                result.append("%20")
            } else {
                let highNibble = Int((byte >> 4) & 0x0F)
                let lowNibble = Int(byte & 0x0F)
                result.append("%")
                result.append(Self.hexEncodeTable[Self.hexEncodeTable.index(Self.hexEncodeTable.startIndex, offsetBy: highNibble)])
                result.append(Self.hexEncodeTable[Self.hexEncodeTable.index(Self.hexEncodeTable.startIndex, offsetBy: lowNibble)])
            }
        }
        return result
    }
}

// MARK: - 加密工具（文档要求的 SHA256/HMAC-SHA256）
extension VolcSigner {
    /// SHA256 小写十六进制编码（文档核心要求）
    private static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data)
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }

    /// HMAC-SHA256 计算（文档签名流程要求）
    private static func hmacSHA256(key: Data, content: Data) throws -> Data {
        let symmetricKey = SymmetricKey(data: key)
        let hmac = HMAC<SHA256>.authenticationCode(for: content, using: symmetricKey)
        return Data(hmac)
    }

    /// 生成 V4 签名密钥（文档步骤：kDate→kRegion→kService→kRequest）
    private func generateSignKey(shortDate: String) throws -> Data {
        guard let skData = sk.data(using: Self.utf8) else {
            throw SignError.invalidSecretKey
        }
        let kDate = try Self.hmacSHA256(key: skData, content: shortDate.data(using: Self.utf8)!)
        let kRegion = try Self.hmacSHA256(key: kDate, content: region.data(using: Self.utf8)!)
        let kService = try Self.hmacSHA256(key: kRegion, content: service.data(using: Self.utf8)!)
        return try Self.hmacSHA256(key: kService, content: "request".data(using: Self.utf8)!)
    }
}

// MARK: - Body 生成工具（适配文档 JSON 示例）
extension VolcSigner {
    /// 生成 Body 数据（文档示例为 JSON 格式）
    private func generateBodyData(
        contentType: RequestContentType,
        businessParams: [String: Any]?
    ) throws -> Data {
        guard let params = businessParams, !params.isEmpty else {
            return Data()
        }

        switch contentType {
        case .json:
            // 文档示例：JSON 无格式化（无空格/换行）
            do {
                return try JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
                throw SignError.jsonSerializationFailed(error.localizedDescription)
            }

        case .formUrlEncoded:
            let sortedParams = params.sorted { $0.key < $1.key }
            var formItems = [String]()
            for (key, value) in sortedParams {
                let encodedKey = urlEncode(key)
                let valueStr: String
                switch value {
                case let boolValue as Bool: valueStr = boolValue ? "true" : "false"
                case let numValue as NSNumber: valueStr = numValue.stringValue
                case let strValue as String: valueStr = strValue
                default: throw SignError.invalidFormParameterType("\(type(of: value)) 不支持")
                }
                let encodedValue = urlEncode(valueStr)
                formItems.append("\(encodedKey)=\(encodedValue)")
            }
            guard let formData = formItems.joined(separator: "&").data(using: Self.utf8) else {
                throw SignError.formEncodingFailed("UTF-8 编码失败")
            }
            return formData
        }
    }

    /// 计算 X-Content-Sha256
    private func calculateXContentSha256(method: String, bodyData: Data) -> String {
        method.uppercased() == "GET" ? Self.getFixedSha256 : Self.sha256(bodyData)
    }
}

// MARK: - 核心请求签名与发送
extension VolcSigner {
    /// 发送请求（异步）
    func sendRequest(
        method: String,
        contentType: RequestContentType,
        businessParams: [String: Any]?,
        action: String,
        version: String
    ) async throws -> (code: Int, body: Data) {
        let requestDate = Date()
        let signedHeaders = "host;x-date;x-content-sha256;content-type"
        let (xDate, shortXDate) = formatDate(requestDate)

        // 1. 生成 Body 并计算 X-Content-Sha256
        let bodyData = try generateBodyData(contentType: contentType, businessParams: businessParams)
        let xContentSha256 = calculateXContentSha256(method: method, bodyData: bodyData)

        // 2. Query 参数
        let queryParams = ["Action": action, "Version": version]
        let sortedQueryItems = queryParams.sorted { $0.key < $1.key }
        var queryString = ""
        for (index, (key, value)) in sortedQueryItems.enumerated() {
            let encodedKey = urlEncode(key)
            let encodedValue = urlEncode(value)
            queryString.append("\(encodedKey)=\(encodedValue)")
            if index != sortedQueryItems.count - 1 {
                queryString.append("&")
            }
        }

        // 3. 构建规范请求（Canonical Request）
        let canonicalRequest = """
        \(method.uppercased())
        \(path.isEmpty ? "/" : path)
        \(queryString)
        host:\(host)
        x-date:\(xDate)
        x-content-sha256:\(xContentSha256)
        content-type:\(contentType.rawValue)

        \(signedHeaders)
        \(xContentSha256)
        """

        // 4. 计算签名字符串（String to Sign）
        let canonicalRequestData = canonicalRequest.data(using: Self.utf8)!
        let hashedCanonicalRequest = Self.sha256(canonicalRequestData)
        let credentialScope = "\(shortXDate)/\(region)/\(service)/request"
        let stringToSign = """
        HMAC-SHA256
        \(xDate)
        \(credentialScope)
        \(hashedCanonicalRequest)
        """

        // 5. 生成签名
        let signKey = try generateSignKey(shortDate: shortXDate)
        let signatureData = try Self.hmacSHA256(
            key: signKey,
            content: stringToSign.data(using: Self.utf8)!
        )
        let signature = signatureData.compactMap { String(format: "%02x", $0) }.joined()

        // 6. 构建 Authorization 头（文档格式）
        let authorization = "HMAC-SHA256 Credential=\(ak)/\(credentialScope), SignedHeaders=\(signedHeaders), Signature=\(signature)"

        // 7. 构建请求
        guard let url = URL(string: "\(schema)://\(host)\(path)?\(queryString)") else {
            throw SignError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.uppercased()
        // 文档要求的请求头
        request.setValue(host, forHTTPHeaderField: "Host")
        request.setValue(xDate, forHTTPHeaderField: "X-Date")
        request.setValue(xContentSha256, forHTTPHeaderField: "X-Content-Sha256")
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        if method.uppercased() != "GET" {
            request.httpBody = bodyData
        }

        // 8. 发送请求
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SignError.invalidResponse
        }
        return (httpResponse.statusCode, data)
    }

    /// 格式化时间（文档要求：yyyyMMdd'T'HHmmss'Z'，GMT 时区）
    private func formatDate(_ date: Date) -> (xDate: String, shortXDate: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let xDate = formatter.string(from: date)
        let shortXDate = String(xDate.prefix(8))
        return (xDate, shortXDate)
    }
}

// MARK: - 错误定义
enum SignError: LocalizedError {
    case invalidSecretKey
    case invalidURL
    case invalidResponse
    case jsonSerializationFailed(String)
    case formEncodingFailed(String)
    case invalidFormParameterType(String)

    var errorDescription: String? {
        switch self {
        case .invalidSecretKey: return "SecretKey 非 UTF-8 编码"
        case .invalidURL: return "构建 URL 失败"
        case .invalidResponse: return "无效 HTTP 响应"
        case let .jsonSerializationFailed(msg): return "JSON 序列化失败：\(msg)"
        case let .formEncodingFailed(msg): return "表单编码失败：\(msg)"
        case let .invalidFormParameterType(msg): return "无效表单参数类型：\(msg)"
        }
    }
}

// MARK: - 文档示例专用调用
struct VolcDocExample {
    static func main() async {
        // 文档示例基础配置（替换为你的实际 AK/SK）
        let ak = "AKLTYWViMTVmZGYzM2E0NDI5Mzk2MDZjNjFmMjc2MjRjMzg"
        let sk = "WkRZeE1EQmxPVGhsWWpWak5HVmtNbUUxTXpZeU9UVXlOMlE1TmpZeVlqTQ=="
        let endpoint = "billing.volcengineapi.com" // 文档示例 Host
        let path = "/" // 文档示例 Path
        let service = "billing" // 文档示例 Service
        let region = "cn-beijing" // 文档示例 Region
        let schema = "https" // 文档示例 Schema

        // 创建签名器
        let signer = VolcSigner(
            region: region,
            service: service,
            schema: schema,
            host: endpoint,
            path: path,
            ak: ak,
            sk: sk
        )

        // 文档示例核心参数
        let action = "ListBill"
        let version = "2022-01-01"
        let businessParams: [String: Any] = ["Limit": 10, "BillPeriod": "2023-08"]
        let contentType: RequestContentType = .json
        let method = "POST"

        // 发送文档示例请求
        print("===== 火山引擎文档示例：POST-JSON 请求 =====")
        do {
            let (code, data) = try await signer.sendRequest(
                method: method,
                contentType: contentType,
                businessParams: businessParams,
                action: action,
                version: version
            )
            let body = String(data: data, encoding: .utf8) ?? "无法解析响应体"
            print("\n=== 响应结果 ===")
            print("响应码: \(code)")
            print("响应体: \(body)")
        } catch {
            print("\n=== 请求失败 ===")
            print("错误: \(error.localizedDescription)")
        }
    }
}
