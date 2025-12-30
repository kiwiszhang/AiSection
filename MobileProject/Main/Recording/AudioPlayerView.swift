//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//

import UIKit
import AVFoundation

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


final class AudioWaveformExtractor {

    static func extractSamples(
        url: URL,
        sampleCount: Int = 100
    ) throws -> [CGFloat] {

        let asset = AVAsset(url: url)
        let track = asset.tracks(withMediaType: .audio).first!

        let reader = try AVAssetReader(asset: asset)

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMBitDepthKey: 16
        ]

        let output = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
        reader.add(output)
        reader.startReading()

        var samples: [CGFloat] = []

        while let buffer = output.copyNextSampleBuffer(),
              let block = CMSampleBufferGetDataBuffer(buffer) {

            let length = CMBlockBufferGetDataLength(block)
            var data = Data(count: length)
            data.withUnsafeMutableBytes {
                CMBlockBufferCopyDataBytes(block, atOffset: 0, dataLength: length, destination: $0.baseAddress!)
            }

            let values = data.withUnsafeBytes {
                Array(UnsafeBufferPointer<Int16>(
                    start: $0.bindMemory(to: Int16.self).baseAddress!,
                    count: length / 2
                ))
            }

            samples.append(contentsOf: values.map { abs(CGFloat($0)) })
        }

        let step = max(1, samples.count / sampleCount)
        return stride(from: 0, to: samples.count, by: step)
            .prefix(sampleCount)
            .map { min(samples[$0] / 32768, 1) }
    }
}

final class AudioPlayerView: UIView {

    private let waveformView = WaveformView()
    private lazy var playButton = UIImageView().image(Asset.pusac.image).onTap { [self] in
        togglePlay()
    }
    private lazy var timeLabel = UILabel().text("3:32").hnFont(size: 10.h, weight: .medium).backgroundColor(.clear).color(kkColorFromHex(kkMainColor)).centerAligned()

    private var player: AVAudioPlayer?
    private var timer: CADisplayLink?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

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

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.duckOthers]
            )
            try session.setActive(true)
        } catch {
            print("AudioSession error:", error)
        }
    }

    func loadAudio(url: URL) {
        setupAudioSession()
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.volume = 1.0   // 明确设置音量
            player?.delegate = self

            DispatchQueue.global(qos: .userInitiated).async {
                let samples = try? AudioWaveformExtractor.extractSamples(
                    url: url,
                    sampleCount: 70   // 👈 控制数量
                )

                DispatchQueue.main.async {
                    self.waveformView.samples = samples ?? []
                }
            }
            timeLabel.text = format(player?.duration ?? 0)

        } catch {
            print("Audio load failed:", error)
        }
    }

    @objc private func togglePlay() {
        guard let player = player else { return }
        if player.isPlaying {
//            player.pause()
//            timer?.invalidate()
//            playButton.image(Asset.pusac.image)
            AudioPlaybackManager.shared.stop(self)
        } else {
//            player.play()
//            startTimer()
//            playButton.image(Asset.playIcon.image)
            AudioPlaybackManager.shared.play(self)
        }
    }

    private func startTimer() {
        timer = CADisplayLink(target: self, selector: #selector(updateProgress))
        timer?.add(to: .main, forMode: .common)
    }

    @objc private func updateProgress() {
        guard let player = player else { return }

        waveformView.progress = CGFloat(player.currentTime / player.duration)
        timeLabel.text = format(player.duration - player.currentTime)

        if !player.isPlaying {
            timer?.invalidate()
        }
    }

    private func format(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

extension AudioPlayerView {
    func play() {
        guard let player = player, !player.isPlaying else { return }
        player.play()
        startTimer()
        playButton.image(Asset.playIcon.image)
    }

    func forcePause() {
        guard let player = player else { return }
        player.pause()
        timer?.invalidate()
        waveformView.progress = 0
        playButton.image(Asset.pusac.image)
    }
}

extension AudioPlayerView: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        AudioPlaybackManager.shared.stop(self)
    }
}




