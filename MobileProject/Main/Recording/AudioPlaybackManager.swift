//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//

import AVFAudio
import MediaPlayer

struct AudioPlaybackState {
    let url: URL
    let isPlaying: Bool
    let progress: CGFloat
    let remain: TimeInterval
}

final class AudioPlaybackManager: NSObject {

    static let shared = AudioPlaybackManager()

    private(set) var player: AVAudioPlayer?
    private weak var currentView: AudioPlayerView?
    private(set) var currentURL: URL?

    private var timer: CADisplayLink?

    private override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommand()
    }

    func play(_ view: AudioPlayerView, url: URL) {
        if currentURL != url {
            stop(currentView)
            load(url)
            currentURL = url       // ✅ 记录当前播放 URL
        }

        currentView = view

        player?.play()
        startTimer()
        broadcast()
    }

    func pause(_ view: AudioPlayerView) {
        player?.pause()
        stopTimer()
        broadcast()
    }

    func stop(_ view: AudioPlayerView?) {
        guard let p = player else { return }
        player?.stop()
        p.currentTime = 0
        stopTimer()
        currentView = nil
        broadcast()
    }

    func seek(progress: CGFloat) {
        guard let p = player else { return }
        p.currentTime = p.duration * progress
        updateNowPlaying()
        broadcast()
    }

    // MARK: - Private

    private func load(_ url: URL) {
        player = try? AVAudioPlayer(contentsOf: url)
        player?.delegate = self
        player?.prepareToPlay()
    }

    private func startTimer() {
        stopTimer()
        timer = CADisplayLink(target: self, selector: #selector(tick))
        timer?.add(to: .main, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func tick() {
        guard let p = player else { return }
        let progress = CGFloat(p.currentTime / p.duration)
        currentView?.onProgress(progress, remain: p.duration - p.currentTime)
        updateNowPlaying()
        broadcast()
    }
}

private extension AudioPlaybackManager {

    func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio)
        try? session.setActive(true)
    }

    func setupRemoteCommand() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            self?.player?.play()
            self?.updateNowPlaying(rate: 1)
            return .success
        }

        center.pauseCommand.addTarget { [weak self] _ in
            self?.player?.pause()
            self?.updateNowPlaying(rate: 0)
            return .success
        }
    }

    func updateNowPlaying(rate: Float = 1) {
        guard let p = player else { return }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: "录音",
            MPMediaItemPropertyPlaybackDuration: p.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: p.currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: rate
        ]
    }
    
    private func broadcast() {
        guard let p = player,
              let url = currentURL else { return }

        let state = AudioPlaybackState(
            url: url,
            isPlaying: p.isPlaying,
            progress: CGFloat(p.currentTime / p.duration),
            remain: p.duration - p.currentTime
        )

        NotificationCenter.default.post(
            name: .audioPlaybackDidUpdate,
            object: state
        )
    }

}

extension AudioPlaybackManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[
            MPNowPlayingInfoPropertyPlaybackRate
        ] = 0
        stop(currentView)
    }
}

extension Notification.Name {
    static let audioPlaybackDidUpdate = Notification.Name("audioPlaybackDidUpdate")
}
