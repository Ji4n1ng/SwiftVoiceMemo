//
//  Date+Ticks.swift
//  SwiftVoiceMemo
//
//  Created by 王嘉宁 on 2017/10/1.
//  Copyright © 2017年 jianing. All rights reserved.
//

import Foundation

extension Date {
    /// 时间戳
    /// - Usage:
    /// - let ticks = Date().ticks
    /// - print(ticks) // 636110903202288256
    /// - let sticks = String(Date().ticks)
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
    
    /// 用时间戳初始化
    /// - parameter ticks: UInt64
    /// - Usage:
    /// - let date = Date(ticks: 636110903202288256)
    init(ticks: UInt64) {
        self.init(timeIntervalSince1970: Double(ticks)/10_000_000 - 62_135_596_800)
    }
}
