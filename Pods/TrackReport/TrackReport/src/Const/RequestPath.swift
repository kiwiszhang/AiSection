//
//  RequestPath.swift
//  TrackReport
//
//  Created by 笔尚文化 on 2025/4/27.
//

import Foundation

struct RequestPath {
    /// 获取配置
    static let appConfig = "/appts/rdb/configs"
    /// 新增用户
    static let addUser = "/appts/rdb/users"
    /// 更新token
    static let updateToken = "/appts/rdb/users"
    /// 事件上报
    static let eventReport = "/appts/rdb/behaviors"
}


