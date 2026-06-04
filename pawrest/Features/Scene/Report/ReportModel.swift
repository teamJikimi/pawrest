//
//  ReportModel.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import Foundation

struct ReportData {
    let weekRange: String
    let summaryTitle: String
    let summaryBody: String
    let aiSummary: String
    let stats: ReportStats
    let statusCards: [StatusCardData]
    let weeklyChart: WeeklyEmotionChartData
    let dailyTimeData: DailyTimeEmotionData
    let weekdayData: WeekdayEmotionData
}

struct ReportStats {
    let recordedDays: Int
    let mostFrequentEmotion: String
    let lettersSent: Int
}

struct StatusCardData: Identifiable {
    let id: UUID
    let title: String
    let date: String
    let score: Int
    let maxScore: Int
    let previousScore: Int
    let previousDate: Date
    let scaleType: ScaleType

    init(id: UUID = UUID(), title: String, date: String, score: Int, maxScore: Int, previousScore: Int, previousDate: Date, scaleType: ScaleType) {
        self.id = id
        self.title = title
        self.date = date
        self.score = score
        self.maxScore = maxScore
        self.previousScore = previousScore
        self.previousDate = previousDate
        self.scaleType = scaleType
    }
}
