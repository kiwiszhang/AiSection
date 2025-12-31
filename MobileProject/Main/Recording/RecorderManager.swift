//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//

import AVFoundation

// MARK: - 录音状态
enum RecordingState {
    case idle        // 未录音
    case recording   // 正在录音
    case paused      // 已暂停
}

enum RecordingEvent {
    case stateChanged(RecordingState)
    case interrupted(reason: String)
}

final class RecorderManager: NSObject {

    static let shared = RecorderManager()

    // MARK: - Audio
    private let session = AVAudioSession.sharedInstance()
    private var recorder: AVAudioRecorder?
    // MARK: - State
    private(set) var state: RecordingState = .idle {
        didSet {
            DispatchQueue.main.async {
                self.onEvent?(.stateChanged(self.state))
            }
        }
    }


    /// 是否正在录音（你要的字段）
    var isRecording: Bool {
        state == .recording
    }

    // MARK: - Time
    private var timer: Timer?
    private(set) var currentDuration: TimeInterval = 0

    // MARK: - File
    private(set) var recordURL: URL?

    // MARK: - Callback
//    var onStateChanged: ((RecordingState) -> Void)?

    var onEvent: ((RecordingEvent) -> Void)?

    // MARK: - Init
    override init() {
        super.init()
        addObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 权限
extension RecorderManager {
    func requestPermission(_ completion: @escaping (Bool) -> Void) {
        switch session.recordPermission {
        case .granted:
            completion(true)

        case .undetermined:
            session.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }

        case .denied:
            completion(false)

        @unknown default:
            completion(false)
        }
    }
    
    /// 判断当前麦克风权限状态
    func microphonePermissionStatus() -> AVAudioSession.RecordPermission {
        return AVAudioSession.sharedInstance().recordPermission
    }
}

// MARK: - Recording Control
extension RecorderManager {

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

    func pause() {
        guard state == .recording else { return }

        recorder?.pause()
        state = .paused
        stopTimer()
    }

    func resume() {
        guard state == .paused else { return }

        recorder?.record()
        state = .recording
        startTimer()
    }

    func stop() {
        guard state != .idle else { return }

        recorder?.stop()
        recorder = nil
        currentDuration = 0

        stopTimer()
        state = .idle
    }

    func recordingDuration() -> TimeInterval {
        recorder?.currentTime ?? currentDuration
    }
}

// MARK: - Session
private extension RecorderManager {

    func setupSession() throws {
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
}

// MARK: - Timer
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

// MARK: - File Management
extension RecorderManager {

    func fetchAllRecordings() -> [URL] {
        let dir = recordingsDirectory()
        let files = (try? FileManager.default.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: nil
        )) ?? []

        return files.filter { $0.pathExtension == "m4a" }
    }

    func deleteRecording(at url: URL) {
        if recordURL == url {
            stop()
        }
        try? FileManager.default.removeItem(at: url)
    }

    func deleteRecordings(_ urls: [URL]) {
        urls.forEach { deleteRecording(at: $0) }
    }
}

// MARK: - File Path
extension RecorderManager {

    public func generateFileURL() -> URL {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd_HHmmss_SSS"

        let timeString = formatter.string(from: Date())
        let uuid = UUID().uuidString.prefix(4)

        let fileName = "\(timeString)_\(uuid).m4a"
        return recordingsDirectory().appendingPathComponent(fileName)
    }



    public func recordingsDirectory() -> URL {
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
}

// MARK: - System Interruption
private extension RecorderManager {

    func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }

    @objc func handleInterruption(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }

        switch type {

        case .began:
            if state == .recording {
                recorder?.pause()
                state = .paused
                stopTimer()
                onEvent?(.interrupted(reason: "录音被系统中断（来电或 Siri）"))
            }
        case .ended:
            let optionsValue =
                info[AVAudioSessionInterruptionOptionKey] as? UInt
            let options = AVAudioSession.InterruptionOptions(
                rawValue: optionsValue ?? 0
            )

            if options.contains(.shouldResume), state == .paused {
                try? session.setActive(true)
//                recorder?.record()
//                state = .recording
                resume()
             }else{
                onEvent?(.interrupted(reason: "录音被其他音频应用占用，已停止"))
//                stop()
            }

        @unknown default:
            break
        }
    }

    @objc func handleRouteChange(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let reasonValue =
                info[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason =
                AVAudioSession.RouteChangeReason(rawValue: reasonValue)
        else { return }

        switch reason {
        case .oldDeviceUnavailable:
            if state == .recording {
                recorder?.pause()
                state = .paused
                stopTimer()
                onEvent?(.interrupted(reason: "录音设备断开，录音已暂停"))
            }
        default:
            break
        }
    }
}
