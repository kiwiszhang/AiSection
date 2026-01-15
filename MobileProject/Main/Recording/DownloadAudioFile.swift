//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//

import Foundation

func downloadAudioFile(
    from remoteURL: URL,
    completion: @escaping (Result<URL, Error>) -> Void
) {
    // 1. 本地目标路径
    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let recordingDir = documents.appendingPathComponent("Recording", isDirectory: true)
    let localURL = recordingDir.appendingPathComponent(remoteURL.lastPathComponent)

    // 2. 确保 Recording 目录存在
    do {
        try FileManager.default.createDirectory(
            at: recordingDir,
            withIntermediateDirectories: true
        )
    } catch {
        completion(.failure(error))
        return
    }

    // 3. 启动下载任务
    let task = URLSession.shared.downloadTask(with: remoteURL) { tempURL, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let tempURL = tempURL else {
            let err = NSError(domain: "DownloadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "临时文件为空"])
            completion(.failure(err))
            return
        }

        // 4. 移动临时文件到目标路径
        do {
            // 如果已存在则先删除
            if FileManager.default.fileExists(atPath: localURL.path) {
                try FileManager.default.removeItem(at: localURL)
            }
            try FileManager.default.moveItem(at: tempURL, to: localURL)
            completion(.success(localURL))
        } catch {
            completion(.failure(error))
        }
    }
    task.resume()
}

