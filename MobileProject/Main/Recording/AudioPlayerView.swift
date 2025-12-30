//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//

import UIKit
import AVFoundation
import MediaPlayer
import Accelerate

final class WaveformView: UIView {

    var samples: [CGFloat] = [] { didSet { setNeedsDisplay() } }
    var progress: CGFloat = 0 { didSet { setNeedsDisplay() } }

    var waveColor = UIColor.systemGray4
    var progressColor = UIColor.systemBlue

    private let amplitudeScale: CGFloat = 4

    override func draw(_ rect: CGRect) {
        guard samples.count > 0 else { return }

        let ctx = UIGraphicsGetCurrentContext()!
        let midY = rect.height / 2
        let step = rect.width / CGFloat(samples.count)

        ctx.setLineCap(.round)
        ctx.setLineWidth(3)

        for i in 0..<samples.count {
            let x = CGFloat(i) * step
            let amp = min(samples[i] * midY * amplitudeScale, midY)

            let color = CGFloat(i) / CGFloat(samples.count) <= progress
                ? progressColor
                : waveColor

            ctx.setStrokeColor(color.cgColor)
            ctx.move(to: CGPoint(x: x, y: midY - amp))
            ctx.addLine(to: CGPoint(x: x, y: midY + amp))
            ctx.strokePath()
        }
    }
}

enum AudioWaveformExtractor {

    /// 工业级波形提取
    /// - Parameters:
    ///   - url: 本地音频文件 URL
    ///   - sampleCount: 最终需要的波形点数量（UI 宽度级别，推荐 60~120）
    static func extract(
        url: URL,
        sampleCount: Int
    ) throws -> [CGFloat] {

        let asset = AVURLAsset(url: url)
        guard let track = asset.tracks(withMediaType: .audio).first else {
            return []
        }

        let reader = try AVAssetReader(asset: asset)

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]

        let output = AVAssetReaderTrackOutput(
            track: track,
            outputSettings: settings
        )

        reader.add(output)
        reader.startReading()

        let samplesPerPixel = max(1, 1024)
        let targetCount = sampleCount

        
        var waveform: [CGFloat] = []
        waveform.reserveCapacity(sampleCount)

        var peak: Float = 0
        var accumulated = 0

        while let buffer = output.copyNextSampleBuffer(),
              let block = CMSampleBufferGetDataBuffer(buffer) {

            let length = CMBlockBufferGetDataLength(block)
            let sampleCount = length / MemoryLayout<Int16>.size

            var samples = [Int16](repeating: 0, count: sampleCount)
            CMBlockBufferCopyDataBytes(
                block,
                atOffset: 0,
                dataLength: length,
                destination: &samples
            )

            for s in samples {
                let v = abs(Float(s))
                peak = max(peak, v)
                accumulated += 1

                if accumulated >= samplesPerPixel {
                    waveform.append(min(CGFloat(peak / 32768), 1))
                    peak = 0
                    accumulated = 0

                    if waveform.count >= targetCount {
                        reader.cancelReading()
                        return waveform
                    }
                }
            }
        }

        return waveform
    }
}

final class AudioPlayerView: UIView {

    private var hasLoadedWaveform = false

    private let waveformView = WaveformView()
    private lazy var playButton = UIImageView()
        .image(Asset.pusac.image)
        .onTap { [weak self] in self?.togglePlay() }

    private let timeLabel = UILabel()
        .hnFont(size: 10.h, weight: .medium)
        .color(kkColorFromHex(kkMainColor))
    private var audioURL: URL?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }
    required init?(coder: NSCoder) { fatalError() }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(onPlaybackUpdate(_:)),
                name: .audioPlaybackDidUpdate,
                object: nil
            )
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }

    private func setupUI() {
        waveformView.backgroundColor = .clear

        addSubview(playButton)
        addSubview(waveformView)
        addSubview(timeLabel)
        
        playButton.snp.makeConstraints { make in
            make.width.height.equalTo(38.h)
            make.left.equalToSuperview().offset(3.w)
            make.centerY.equalToSuperview()
        }
        
        let widthL = "003:32".width(forFont: UIFont.interOner(size: 10.h, weight: .medium))
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(playButton)
            make.right.equalToSuperview().offset(-5.w)
            make.height.equalTo(12.h)
            make.width.equalTo(widthL + 10.w)
        }
        
        waveformView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(playButton.snp.right).offset(8.w)
            make.right.equalTo(timeLabel.snp.left).offset(-4.w)
        }

    }

    private func setupGesture() {
        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleWaveformPan(_:))
        )
        waveformView.addGestureRecognizer(pan)
    }

    @objc private func onPlaybackUpdate(_ n: Notification) {
        guard let state = n.object as? AudioPlaybackState else { return }
        guard state.url == audioURL else { return }

        onPlayStateChanged(isPlaying: state.isPlaying)
        onProgress(state.progress, remain: state.remain)
    }

    
    @objc private func handleWaveformPan(_ g: UIPanGestureRecognizer) {
        let x = g.location(in: waveformView).x
        let progress = min(max(x / waveformView.bounds.width, 0), 1)
        AudioPlaybackManager.shared.seek(progress: progress)
    }

    
    func configure(url: URL, duration: TimeInterval) {
        self.audioURL = url
        timeLabel.text = format(duration)
        waveformView.progress = 0
        loadWaveform(url: url)
    }
    
    private func loadWaveform(url: URL) {

        if let cached = WaveformCache.shared.waveform(for: url) {
            waveformView.samples = cached
            return
        }

        DispatchQueue.global(qos: .utility).async {
            let waveform = (try? AudioWaveformExtractor.extract(
                url: url,
                sampleCount: 70
            )) ?? []

            DispatchQueue.main.async {
                WaveformCache.shared.store(waveform, for: url)
                self.waveformView.samples = waveform
            }
        }
    }


    // MARK: - UI Update (由 Manager 调用)

    func onPlayStateChanged(isPlaying: Bool) {
        playButton.image(isPlaying ? Asset.playIcon.image : Asset.pusac.image)
    }

    func onProgress(_ progress: CGFloat, remain: TimeInterval) {
        waveformView.progress = progress
        timeLabel.text = format(remain)
    }

    func onPlayFinished() {
        waveformView.progress = 1
        playButton.image(Asset.pusac.image)
    }
    // MARK: - Actions
    private func togglePlay() {
        guard let url = audioURL else { return }
        let manager = AudioPlaybackManager.shared

        if manager.player?.isPlaying == true {
            manager.pause(self)
        } else {
            manager.play(self, url: url)
        }
    }
    
    private func format(_ t: TimeInterval) -> String {
        guard t.isFinite, t >= 0 else { return "00:00" }
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }

}
final class WaveformCache {

    static let shared = WaveformCache()
    private init() {}

    private var memory: [URL: [CGFloat]] = [:]

    func waveform(for url: URL) -> [CGFloat]? {
        memory[url]
    }

    func store(_ waveform: [CGFloat], for url: URL) {
        memory[url] = waveform
    }
}







