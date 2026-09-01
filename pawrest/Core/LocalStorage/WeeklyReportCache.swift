//
//  WeeklyReportCache.swift
//  pawrest
//
//  Created by 소은 on 8/18/26.
//

import SwiftData
import Foundation

@Model
final class WeeklyReportCache {
    var weekEndDate: Date        // 이번 주 일요일 날짜 (캐시 키)
    var snapshotHash: String     // 감정 기록 해시 (데이터 변경 감지)
    var summaryTitle: String
    var summaryBody: String
    var aiSummary: String
    var weeklyInsight: String?
    var weekdayInsight: String?
    var timeInsight: String?
    var createdAt: Date

    init(
        weekEndDate: Date,
        snapshotHash: String,
        summaryTitle: String,
        summaryBody: String,
        aiSummary: String,
        weeklyInsight: String?,
        weekdayInsight: String?,
        timeInsight: String?
    ) {
        self.weekEndDate = weekEndDate
        self.snapshotHash = snapshotHash
        self.summaryTitle = summaryTitle
        self.summaryBody = summaryBody
        self.aiSummary = aiSummary
        self.weeklyInsight = weeklyInsight
        self.weekdayInsight = weekdayInsight
        self.timeInsight = timeInsight
        self.createdAt = Date()
    }
}
