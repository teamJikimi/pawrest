//
//  ReportUseCase.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import Foundation

protocol ReportUseCaseProtocol {
    func fetchReportData() async throws -> ReportData
    func fetchDailyTimeEmotion(for date: Date) async throws -> DailyTimeEmotionData
}

struct ReportUseCase: ReportUseCaseProtocol {
    func fetchReportData() async throws -> ReportData {
        return ReportData(
            weekRange: weekRangeString(),
            summaryTitle: "",
            summaryBody: "",
            aiSummary: "",
            stats: ReportStats(recordedDays: 0, mostFrequentEmotion: "", lettersSent: 0),
            statusCards: [],
            weeklyChart: WeeklyEmotionChartData(entries: [], insight: nil),
            dailyTimeData: DailyTimeEmotionData(date: Date(), slots: [], insight: nil),
            weekdayData: WeekdayEmotionData(entries: [], insight: nil)
        )
    }

    func fetchDailyTimeEmotion(for date: Date) async throws -> DailyTimeEmotionData {
        return DailyTimeEmotionData(date: date, slots: [], insight: nil)
    }

    private func weekRangeString() -> String {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        let weekday = calendar.component(.weekday, from: now)
        let daysFromMonday = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: now),
              let sunday = calendar.date(byAdding: .day, value: 6, to: monday) else { return "" }
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = ", yyyy"
        return "\(formatter.string(from: monday)) - \(formatter.string(from: sunday))\(yearFormatter.string(from: sunday))"
    }
}
