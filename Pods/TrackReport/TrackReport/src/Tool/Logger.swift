//
//  Logger.swift
//  TrackReport
//
//  Created by 笔尚文化 on 2025/4/27.
//

import Foundation

public func kLog<T>(_ message: T) {
    #if DEBUG
    print("[TrackReportKit] 🔥 \(message)")
    #endif
}
