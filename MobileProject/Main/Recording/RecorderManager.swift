//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//

import AVFoundation

enum RecordingState {
    case idle        // 未录音
    case recording   // 正在录音
    case paused      // 已暂停
}


final class RecorderManager: NSObject {

    static let shared = RecorderManager()

    private var recorder: AVAudioRecorder?
    private let session = AVAudioSession.sharedInstance()

    private(set) var recordURL: URL?

    /// 录音开始时间（用于 UI 统计）
    private var timer: Timer?
    private(set) var currentDuration: TimeInterval = 0

    /// 当前录音状态
    private(set) var state: RecordingState = .idle

    /// 是否正在录音
    var isRecording: Bool {
        return state == .recording
    }

    
    // MARK: - 权限请求
    func requestPermission(_ completion: @escaping (Bool) -> Void) {
        session.requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // MARK: - 开始录音
    func startRecording() throws {
        guard state == .idle else { return }
        
        try setupSession()

        let url = generateFileURL()
        recordURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.isMeteringEnabled = true
        recorder?.prepareToRecord()
        recorder?.record()
        
        state = .recording

        startTimer()
    }

    // MARK: - 暂停
    func pause() {
        guard state == .recording else { return }

        recorder?.pause()
        
        state = .paused

        stopTimer()
    }

    // MARK: - 继续
    func resume() {
        guard state == .paused else { return }

        recorder?.record()
        
        state = .recording

        startTimer()
    }

    // MARK: - 停止
    func stop() {
        guard state != .idle else { return }

        recorder?.stop()
        recorder = nil
        
        state = .idle

        stopTimer()
    }

    // MARK: - 当前录音时长
    func recordingDuration() -> TimeInterval {
        return recorder?.currentTime ?? currentDuration
    }

    // MARK: - Session
    private func setupSession() throws {
        try session.setCategory(
            .playAndRecord,
            mode: .default,
            options: [
                .defaultToSpeaker,
                .allowBluetooth,
                .allowBluetoothA2DP
            ]
        )
        try session.setActive(true)
    }

    // MARK: - 文件路径
    private func generateFileURL() -> URL {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd_HHmmss_SSS"

        let fileName = "record_\(formatter.string(from: Date())).m4a"

        let recordingDir = recordingsDirectory()
        return recordingDir.appendingPathComponent(fileName)
    }


    private func recordingsDirectory() -> URL {
        let documents = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        let dir = documents.appendingPathComponent("Recording")

        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(
                at: dir,
                withIntermediateDirectories: true
            )
        }
        return dir
    }

    /// 获取所有录音文件
    func fetchAllRecordings() -> [URL] {
        let dir = recordingsDirectory()
        let files = (try? FileManager.default.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: nil
        )) ?? []

        return files.filter { $0.pathExtension == "m4a" }
    }
    /// 单个删除
    func deleteRecording(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }

    /// 批量删除
    func deleteRecordings(_ urls: [URL]) {
        urls.forEach {
            try? FileManager.default.removeItem(at: $0)
        }
    }

}

private extension RecorderManager {

    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.currentDuration = self.recorder?.currentTime ?? 0
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
