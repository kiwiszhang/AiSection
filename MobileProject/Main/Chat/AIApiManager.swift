//
//  AIApiManager.swift
//  collage
//
//  Created by 笔尚文化 on 2025/11/10.
//

import Foundation

final class AIApiManager {
    static let shared = AIApiManager()
    private init() {}

    /// 文本翻译
    /// https://www.volcengine.com/docs/4640/65067
    /// - Parameters:
    ///   - textList: 待翻译的文本列表（列表长度不超过16，总文本长度不超过5000字符）
    ///   - targetLanguage: 目标语言，默认中文（可在语言支持中查询对应的语言代码）
    /// - Returns: 翻译结果
    func translate(textList: [String], targetLanguage: String = "zh") async throws -> [String] {
        let signer = VolcSigner(
            region: "cn-north-1",
            service: "translate",
            schema: "https",
            host: "translate.volcengineapi.com",
            path: ""
        )

        let (responseCode, responseData) = try await signer.sendRequest(
            method: "POST",
            contentType: .json,
            businessParams: [
                "TextList": textList,
                "TargetLanguage": targetLanguage,
            ],
            action: "TranslateText",
            version: "2020-06-01"
        )
        guard responseCode == 200 else {
            throw RemoteError.statusCode(responseCode)
        }
        guard let result = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            throw RemoteError.invalidResponse
        }
        guard let translationList = result["TranslationList"] as? [[String: Any]] else {
            throw RemoteError.requestFailed("翻译结果解析错误")
        }
        return translationList.compactMap {
            $0["Translation"] as? String
        }
    }

    /// 涂抹消除
    /// https://www.volcengine.com/docs/86081/1804489
    /// - Parameters:
    ///   - originalImageData: 原图
    ///   - maskImageData: 涂抹的mask
    /// - Returns: 结果图
    func imagePaintRemove(originalImageData: Data, maskImageData: Data) async throws -> Data {
        let base64StringArr = [originalImageData.base64EncodedString(), maskImageData.base64EncodedString()]
        let signer = VolcSigner(
            region: "cn-north-1",
            service: "cv",
            schema: "https",
            host: "visual.volcengineapi.com",
            path: ""
        )

        let (responseCode, responseData) = try await signer.sendRequest(
            method: "POST",
            contentType: .json,
            businessParams: [
                "req_key": "i2i_inpainting",
                "binary_data_base64": base64StringArr,
                "quality": "H",
            ],
            action: "Img2ImgInpainting",
            version: "2022-08-31"
        )
        guard responseCode == 200 else {
            throw RemoteError.statusCode(responseCode)
        }
        guard let result = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            throw RemoteError.invalidResponse
        }
        guard result["code"] as? Int == 10000 else {
            throw RemoteError.requestFailed(result["message"] as? String ?? "API 返回非成功状态码")
        }
        guard let data = result["data"] as? [String: Any],
              let binary_data_base64 = data["binary_data_base64"] as? [String],
              let imageBase64String = binary_data_base64.first,
              let imageData = Data(base64Encoded: imageBase64String, options: .ignoreUnknownCharacters) else {
            throw RemoteError.requestFailed(result["message"] as? String ?? "Unknown Error")
        }
        return imageData
    }

    /// 图像增强
    /// https://www.volcengine.com/docs/86081/1660426
    /// - Parameter imageData: 待增强的图片
    /// - Returns: 结果图
    func imageEnhancement(imageData: Data) async throws -> Data {
        let base64StringArr = [imageData.base64EncodedString()]
        let signer = VolcSigner(
            region: "cn-north-1",
            service: "cv",
            schema: "https",
            host: "visual.volcengineapi.com",
            path: ""
        )

        let (responseCode, responseData) = try await signer.sendRequest(
            method: "POST",
            contentType: .json,
            businessParams: [
                "req_key": "lens_lqir",
                "binary_data_base64": base64StringArr,
            ],
            action: "CVProcess",
            version: "2022-08-31"
        )
        guard responseCode == 200 else {
            throw RemoteError.statusCode(responseCode)
        }
        guard let result = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            throw RemoteError.invalidResponse
        }
        guard result["code"] as? Int == 10000 else {
            throw RemoteError.requestFailed(result["message"] as? String ?? "API 返回非成功状态码")
        }
        guard let data = result["data"] as? [String: Any],
              let binary_data_base64 = data["binary_data_base64"] as? [String],
              let imageBase64String = binary_data_base64.first,
              let imageData = Data(base64Encoded: imageBase64String, options: .ignoreUnknownCharacters) else {
            throw RemoteError.requestFailed(result["message"] as? String ?? "Unknown Error")
        }
        return imageData
    }

    /// 图生图（即梦图生图3.0智能参考）
    /// https://www.volcengine.com/docs/85621/1747301
    /// - Parameters:
    ///   - imageData: 原始图片
    ///   - prompt: 提示词
    ///   - imageRatio: 图片宽高比
    /// - Returns: 结果图
    func imageToImage(imageData: Data, prompt: String, imageRatio: CGFloat) async throws -> Data {
        let base64StringArr = [imageData.base64EncodedString()]
        let signer = VolcSigner(
            region: "cn-north-1",
            service: "cv",
            schema: "https",
            host: "visual.volcengineapi.com",
            path: ""
        )

        let outputSize = resetImageSize(with: imageRatio, maxSideLength: 2016)
        let (responseCode, responseData) = try await signer.sendRequest(
            method: "POST",
            contentType: .json,
            businessParams: [
                "req_key": "jimeng_i2i_v30",
                "binary_data_base64": base64StringArr,
                "prompt": prompt,
                "width": outputSize.width,
                "height": outputSize.height,
            ],
            action: "CVSync2AsyncSubmitTask",
            version: "2022-08-31"
        )
        guard responseCode == 200 else {
            throw RemoteError.statusCode(responseCode)
        }
        guard let result = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            throw RemoteError.invalidResponse
        }
        guard result["code"] as? Int == 10000 else {
            throw RemoteError.requestFailed(result["message"] as? String ?? "API 返回非成功状态码")
        }

        guard let data = result["data"] as? [String: Any],
              let taskId = data["task_id"] as? String else {
            throw RemoteError.requestFailed("响应数据格式异常，缺少 data 或 taskId 字段")
        }
        try await Task.sleep(nanoseconds: 5 * 1000000000)
        return try await fetchGenerateResult(reqKey: "jimeng_i2i_v30", taskId: taskId)
    }
    
    /// AI扩图
    /// https://www.volcengine.com/docs/86081/1804491
    /// - Parameters:
    ///   - originalImageData: 需扩展的图
    ///   - maskImageData: 需扩展的图蒙版
    ///   - prompt: 提示词
    /// - Returns: 结果图
    func imageExpand(originalImageData: Data, maskImageData: Data, prompt: String?) async throws -> Data {
        let base64StringArr = [originalImageData.base64EncodedString(), maskImageData.base64EncodedString()]
        let signer = VolcSigner(
            region: "cn-north-1",
            service: "cv",
            schema: "https",
            host: "visual.volcengineapi.com",
            path: ""
        )
        var businessParams: [String: Any] = [
            "req_key": "i2i_outpainting",
            "binary_data_base64": base64StringArr
        ]
        if let prompt {
            businessParams["custom_prompt"] = prompt
        }
        let (responseCode, responseData) = try await signer.sendRequest(
            method: "POST",
            contentType: .json,
            businessParams: businessParams,
            action: "CVProcess",
            version: "2022-08-31"
        )
        guard responseCode == 200 else {
            throw RemoteError.statusCode(responseCode)
        }
        guard let result = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            throw RemoteError.invalidResponse
        }
        guard result["code"] as? Int == 10000 else {
            throw RemoteError.requestFailed(result["message"] as? String ?? "API 返回非成功状态码")
        }
        guard let data = result["data"] as? [String: Any],
              let binary_data_base64 = data["binary_data_base64"] as? [String],
              let imageBase64String = binary_data_base64.first,
              let imageData = Data(base64Encoded: imageBase64String, options: .ignoreUnknownCharacters) else {
            throw RemoteError.requestFailed(result["message"] as? String ?? "Unknown Error")
        }
        return imageData
    }
    
    /// 文生图（通用3.0-文生图）
    /// https://www.volcengine.com/docs/86081/1804549
    /// - Parameters:
    ///   - prompt: 提示词
    ///   - scale: 影响文本描述的程度，取值范围：[1, 10]
    ///   - imageWidth: 生成图像的宽
    ///   - imageHeight: 生成图像的高
    /// - Returns: 结果图
    func textToImage(
        prompt: String,
        scale: CGFloat = 2.5,
        imageWidth: CGFloat = 1328,
        imageHeight: CGFloat = 1328
    ) async throws -> Data {
        let signer = VolcSigner(
            region: "cn-north-1",
            service: "cv",
            schema: "https",
            host: "visual.volcengineapi.com",
            path: ""
        )

        let outputSize = limitImageSize(originalWidth: imageWidth, originalHeight: imageHeight, maxSideLength: 2048)
        let (responseCode, responseData) = try await signer.sendRequest(
            method: "POST",
            contentType: .json,
            businessParams: [
                "req_key": "high_aes_general_v30l_zt2i",
                "prompt": prompt,
                "use_pre_llm": prompt.count <= 30,
                "scale": scale,
                "width": outputSize.width,
                "height": outputSize.height,
            ],
            action: "CVSync2AsyncSubmitTask",
            version: "2022-08-31"
        )
        guard responseCode == 200 else {
            throw RemoteError.statusCode(responseCode)
        }
        guard let result = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            throw RemoteError.invalidResponse
        }
        guard result["code"] as? Int == 10000 else {
            throw RemoteError.requestFailed(result["message"] as? String ?? "API 返回非成功状态码")
        }

        guard let data = result["data"] as? [String: Any],
              let taskId = data["task_id"] as? String else {
            throw RemoteError.requestFailed("响应数据格式异常，缺少 data 或 taskId 字段")
        }
        try await Task.sleep(nanoseconds: 5 * 1000000000)
        return try await fetchGenerateResult(reqKey: "high_aes_general_v30l_zt2i", taskId: taskId)
    }
    
    /// AIGC-图像人脸融合
    /// https://www.volcengine.com/docs/86081/1804504
    /// - Parameters:
    ///   - targetImageData: 用户图
    ///   - templateImageData: 模板图
    /// - Returns: 结果图
    func faceSwap(targetImageData: Data, templateImageData: Data) async throws -> Data {
        let base64StringArr = [targetImageData.base64EncodedString(), templateImageData.base64EncodedString()]
        let signer = VolcSigner(
            region: "cn-north-1",
            service: "cv",
            schema: "https",
            host: "visual.volcengineapi.com",
            path: ""
        )
        let businessParams: [String: Any] = [
            "req_key": "aigc_face_swap_v1",
            "binary_data_base64": base64StringArr
        ]
        let (responseCode, responseData) = try await signer.sendRequest(
            method: "POST",
            contentType: .json,
            businessParams: businessParams,
            action: "CVProcess",
            version: "2022-08-31"
        )
        guard responseCode == 200 else {
            throw RemoteError.statusCode(responseCode)
        }
        guard let result = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            throw RemoteError.invalidResponse
        }
        guard result["code"] as? Int == 10000 else {
            throw RemoteError.requestFailed(result["message"] as? String ?? "API 返回非成功状态码")
        }
        guard let data = result["data"] as? [String: Any],
              let binary_data_base64 = data["binary_data_base64"] as? [String],
              let imageBase64String = binary_data_base64.first,
              let imageData = Data(base64Encoded: imageBase64String, options: .ignoreUnknownCharacters) else {
            throw RemoteError.requestFailed(result["message"] as? String ?? "Unknown Error")
        }
        return imageData
    }
}

extension AIApiManager {
    enum RemoteError: Error {
        case invalidResponse
        case statusCode(Int)
        case requestFailed(String)
        case taskTimeout(String)
    }
}

private
extension AIApiManager {
    func fetchGenerateResult(reqKey: String, taskId: String) async throws -> Data {
        let signer = VolcSigner(
            region: "cn-north-1",
            service: "cv",
            schema: "https",
            host: "visual.volcengineapi.com",
            path: ""
        )
        let (responseCode, responseData) = try await signer.sendRequest(
            method: "POST",
            contentType: .json,
            businessParams: [
                "req_key": reqKey,
                "task_id": taskId,
            ],
            action: "CVSync2AsyncGetResult",
            version: "2022-08-31"
        )
        guard responseCode == 200 else {
            throw RemoteError.statusCode(responseCode)
        }
        guard let result = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            throw RemoteError.invalidResponse
        }
        guard result["code"] as? Int == 10000 else {
            throw RemoteError.requestFailed(result["message"] as? String ?? "API 返回非成功状态码")
        }
        guard let data = result["data"] as? [String: Any],
              let status = data["status"] as? String else {
            throw RemoteError.requestFailed("响应数据格式异常，缺少 data 或 status 字段")
        }
        guard ["done", "not_found", "expired"].contains(status) else {
            MyLog("任务未完成（状态：\(status)），5秒后重试...")
            // 延时5秒（1秒=1e9纳秒，5秒=5e9纳秒）
            try await Task.sleep(nanoseconds: 5 * 1000000000)
            return try await fetchGenerateResult(
                reqKey: reqKey,
                taskId: taskId
            )
        }
        // 任务完成/结束，解析 base64 图片数据
        guard let binaryDataBase64 = data["binary_data_base64"] as? [String],
              let imageBase64String = binaryDataBase64.first,
              let imageData = Data(base64Encoded: imageBase64String, options: .ignoreUnknownCharacters) else {
            throw RemoteError.requestFailed("图片 base64 解析失败：\(result["message"] as? String ?? "未知错误")")
        }
        return imageData
    }
}

private
extension AIApiManager {
    /// 重置图片宽高
    /// - Parameter imageRatio: 原始宽高比（width/height）
    /// - Parameter maxSideLength: 最长边长
    /// - Returns: (width: 计算后宽, height: 计算后高)
    func resetImageSize(with imageRatio: CGFloat, maxSideLength: CGFloat) -> (width: Int, height: Int) {
        guard imageRatio > 0 else {
            return (Int(maxSideLength), Int(maxSideLength))
        }
        var targetWidth: CGFloat
        var targetHeight: CGFloat

        if imageRatio >= 1 {
            // 横图/正方形：宽为最长边
            targetWidth = maxSideLength
            targetHeight = maxSideLength / imageRatio
        } else {
            // 竖图：高为最长边
            targetHeight = maxSideLength
            targetWidth = maxSideLength * imageRatio
        }

        return (Int(targetWidth), Int(targetHeight))
    }
    
    /// 限制图片宽高（最长边不超过maxSideLength，等比缩放，不放大）
    /// - Parameters:
    ///   - originalWidth: 原始宽度（px）
    ///   - originalHeight: 原始高度（px）
    ///   - maxSideLength: 最大边长（px）
    /// - Returns: (width: 计算后宽, height: 计算后高)
    func limitImageSize(
        originalWidth: CGFloat,
        originalHeight: CGFloat,
        maxSideLength: CGFloat
    ) -> (width: Int, height: Int) {
        guard originalWidth > 0, originalHeight > 0, maxSideLength > 0 else {
            return (64, 64)
        }
        
        let maxOriginalSide = max(originalWidth, originalHeight)
        // 最长边≤最大值 → 直接返回
        if maxOriginalSide <= maxSideLength {
            return (Int(round(originalWidth)), Int(round(originalHeight)))
        }
        
        // 等比缩放 + 兜底不超界
        let scale = maxSideLength / maxOriginalSide
        let maxInt = Int(maxSideLength)
        let finalWidth = min(Int(round(originalWidth * scale)), maxInt)
        let finalHeight = min(Int(round(originalHeight * scale)), maxInt)
        
        return (max(finalWidth, 1), max(finalHeight, 1))
    }
}
