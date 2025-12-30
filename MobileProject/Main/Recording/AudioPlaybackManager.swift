//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//

final class AudioPlaybackManager {
    static let shared = AudioPlaybackManager()
    private weak var currentPlayer: AudioPlayerView?
    private init() {}
    func play(_ player: AudioPlayerView) {
        if currentPlayer !== player {
            currentPlayer?.forcePause()
            currentPlayer = player
        }
        player.play()
    }
    func stop(_ player: AudioPlayerView) {
        if currentPlayer === player {
            currentPlayer = nil
        }
        player.forcePause()
    }
}



