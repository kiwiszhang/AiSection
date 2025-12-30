//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//

import UIKit
import AVFoundation
import DSWaveformImage
import DSWaveformImageViews

final class AudioWavePlayerView: UIView {

    private let playBtn = UIButton(type: .system)
    private let timeLabel = UILabel()
    private let waveformView = WaveformImageView(frame: .zero)
    private let progressLayer = CALayer()

    private var player: AVAudioPlayer?
    private var timer: Timer?

    private var duration: TimeInterval = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 28
        clipsToBounds = true

        playBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playBtn.tintColor = .white
        playBtn.backgroundColor = .systemBlue
        playBtn.layer.cornerRadius = 24
        playBtn.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)

        timeLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        timeLabel.textColor = .systemBlue
        timeLabel.textAlignment = .right
        timeLabel.text = "0:00"

        waveformView.backgroundColor = .clear

        addSubview(playBtn)
        addSubview(waveformView)
        addSubview(timeLabel)

        // 叠加进度层
        waveformView.layer.addSublayer(progressLayer)
        progressLayer.backgroundColor = UIColor.systemBlue.cgColor
        progressLayer.frame = .zero
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        playBtn.frame = CGRect(x: 12, y: (bounds.height - 48)/2, width: 48, height: 48)

        let waveformX = playBtn.frame.maxX + 12
        let waveWidth = bounds.width - waveformX - 60
        waveformView.frame = CGRect(x: waveformX, y: 12, width: waveWidth, height: bounds.height - 24)

        timeLabel.frame = CGRect(x: bounds.width - 52, y: 0, width: 48, height: bounds.height)

        // 先设置底色，进度后面更新
        progressLayer.frame = CGRect(x: 0, y: 0, width: 0, height: waveformView.bounds.height)
    }

    func configure(url: URL) {
        waveformView.waveformAudioURL = url

        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        duration = player?.duration ?? 0
        timeLabel.text = format(duration)
    }

    @objc private func didTapPlay() {
        guard let p = player else { return }

        if p.isPlaying {
            p.pause()
            stopTimer()
            playBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            p.play()
            startTimer()
            playBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateProgress() {
        guard let p = player, duration > 0 else { return }

        // 进度比例
        let prog = CGFloat(p.currentTime / duration)

        // 更新进度层宽度
        let width = waveformView.bounds.width * prog
        progressLayer.frame.size.width = width

        // 倒计时
        timeLabel.text = format(duration - p.currentTime)
    }

    private func format(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}



