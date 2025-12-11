//
//  ShareManager.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/4/14.
//

import UIKit
import LinkPresentation
import AVFoundation

// MARK: - 分享内容配置
struct ShareContent {
    var text: String?
    var image: UIImage?
    var url: URL?
    var videoURL: URL?
    
    var isEmpty: Bool {
        text == nil && image == nil && url == nil && videoURL == nil
    }
}

final class ShareManager {
    static let shared = ShareManager()
    private init() {}
    
    // MARK: - 复合分享（文本+图片+链接+视频）
    func shareAll(content: ShareContent,
                 excludedActivities: [UIActivity.ActivityType]? = nil,
                 sourceView: UIView? = nil,
                 completion: ((Bool) -> Void)? = nil) {
        guard !content.isEmpty else {
            completion?(false)
            return
        }
        
        var activityItems: [Any] = []
        // 文本/图片/链接
        
        if let textContent = content.text {
            activityItems.append(TextActivityItem(text: textContent))
        }
        if let imageContent = content.image {
            activityItems.append(ImageActivityItem(image: imageContent))
        }
        
        if let urlContent = content.url {
            activityItems.append(URLActivityItem(url: urlContent))
        }
        
//        if content.text != nil || content.image != nil || content.url != nil {
//            activityItems.append(UniversalActivityItem(
//                text: content.text,
//                image: content.image,
//                url: content.url
//            ))
//        }

        // 视频
        if let videoURL = content.videoURL {
            activityItems.append(VideoActivityItem(videoURL: videoURL))
        }
        
        presentActivityController(
            with: activityItems,
            excludedActivities: excludedActivities,
            sourceView: sourceView,
            completion: completion
        )
    }
    
    // MARK: - 单独分享方法
    func shareText(_ text: String,
                   excludedActivities: [UIActivity.ActivityType]? = nil,
                   sourceView: UIView? = nil,
                   completion: ((Bool) -> Void)? = nil) {
        presentActivityController(
            with: [TextActivityItem(text: text)],
            excludedActivities: excludedActivities,
            sourceView: sourceView,
            completion: completion
        )
    }
    
    func shareImage(_ image: UIImage,
                    excludedActivities: [UIActivity.ActivityType]? = nil,
                    sourceView: UIView? = nil,
                    completion: ((Bool) -> Void)? = nil) {
        presentActivityController(
            with: [ImageActivityItem(image: image)],
            excludedActivities: excludedActivities,
            sourceView: sourceView,
            completion: completion
        )
    }
    
    func shareURL(_ url: URL,
                  title: String? = nil,
                  excludedActivities: [UIActivity.ActivityType]? = nil,
                  sourceView: UIView? = nil,
                  completion: ((Bool) -> Void)? = nil) {
        presentActivityController(
            with: [URLActivityItem(url: url, title: title)],
            excludedActivities: excludedActivities,
            sourceView: sourceView,
            completion: completion
        )
    }
    
    func shareVideo(_ videoURL: URL,
                   thumbnail: UIImage? = nil,
                   excludedActivities: [UIActivity.ActivityType]? = nil,
                   sourceView: UIView? = nil,
                   completion: ((Bool) -> Void)? = nil) {
        let item = VideoActivityItem(
            videoURL: videoURL,
            thumbnail: thumbnail ?? generateVideoThumbnail(url: videoURL)
        )
        presentActivityController(
            with: [item],
            excludedActivities: excludedActivities,
            sourceView: sourceView,
            completion: completion
        )
    }
    
    // MARK: - 私有工具方法
    private func presentActivityController(
        with activityItems: [Any],
        excludedActivities: [UIActivity.ActivityType]? = nil,
        sourceView: UIView? = nil,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard !activityItems.isEmpty else {
            completion?(false)
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // 排除不支持的活动类型
        var excluded = excludedActivities ?? []
        excluded.append(contentsOf: [
            .assignToContact,
            .addToReadingList,
            .print
        ])
        activityVC.excludedActivityTypes = excluded
        
        // 配置弹出视图（iPad兼容）
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = sourceView ?? UIApplication.shared.keyWindow?.rootViewController?.view
            popover.sourceRect = sourceView?.bounds ?? CGRect(
                x: UIScreen.main.bounds.midX,
                y: UIScreen.main.bounds.midY,
                width: 0,
                height: 0
            )
        }
        
        activityVC.completionWithItemsHandler = { _, completed, _, _ in
            completion?(completed)
        }
        
        UIApplication.topViewController()?.present(activityVC, animated: true)
    }
    
    private func generateVideoThumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(
                at: CMTime(seconds: 1, preferredTimescale: 60),
                actualTime: nil
            )
            return UIImage(cgImage: cgImage)
        } catch {
            print("生成视频缩略图失败: \(error)")
            return nil
        }
    }
}

// MARK: - 分享项实现
private class UniversalActivityItem: NSObject, UIActivityItemSource {
    
    let text: String?
    let image: UIImage?
    let url: URL?
    
    init(text: String?, image: UIImage?, url: URL?) {
        self.text = text
        self.image = image
        self.url = url
    }
    
    func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return text ?? url ?? image ?? ""
    }
    
    func activityViewController(
        _: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        switch activityType {
        case .mail, .message:
            return [text!,url!,image!]
        default:
            return [text!,url!,image!]
        }
    }
    
    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(
        _: UIActivityViewController
    ) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = text ?? "分享内容"
        metadata.url = url
        
        if let image = image {
            metadata.imageProvider = NSItemProvider(object: image)
        }
        
        return metadata
    }
}

private class TextActivityItem: NSObject, UIActivityItemSource {
    let text: String
    
    init(text: String) {
        self.text = text
    }
    
    func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return text
    }
    
    func activityViewController(
        _: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        return text
    }
    
    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = text
        return metadata
    }
}

private class ImageActivityItem: NSObject, UIActivityItemSource {
    let image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return image
    }
    
    func activityViewController(
        _: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        return image
    }
    
    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.imageProvider = NSItemProvider(object: image)
        return metadata
    }
}

private class URLActivityItem: NSObject, UIActivityItemSource {
    let url: URL
    let title: String?
    
    init(url: URL, title: String? = nil) {
        self.url = url
        self.title = title
    }
    
    func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return url
    }
    
    func activityViewController(
        _: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        return url
    }
    
    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.url = url
        metadata.originalURL = url
        metadata.title = title ?? url.absoluteString
        return metadata
    }
}

private class VideoActivityItem: NSObject, UIActivityItemSource {
    let videoURL: URL
    let thumbnail: UIImage?
    
    init(videoURL: URL, thumbnail: UIImage? = nil) {
        self.videoURL = videoURL
        self.thumbnail = thumbnail
    }
    
    func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return videoURL
    }
    
    func activityViewController(
        _: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        return videoURL
    }
    
    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.url = videoURL
        metadata.originalURL = videoURL
        metadata.title = "视频分享"
        
        if let thumbnail = thumbnail {
            metadata.imageProvider = NSItemProvider(object: thumbnail)
        }
        
        return metadata
    }
}
