//
//  ReportUseCase.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import Foundation

protocol ReportUseCaseProtocol {
    func fetchReportData(emotionSnapshots: [EmotionSnapshot]) async throws -> ReportData
    func fetchDailyTimeEmotion(for date: Date, emotionSnapshots: [EmotionSnapshot]) async throws -> DailyTimeEmotionData
}

struct ReportUseCase: ReportUseCaseProtocol {
    func fetchReportData(emotionSnapshots: [EmotionSnapshot]) async throws -> ReportData {
        let calendar = Calendar.current
        let today = Date()

        let weeklyEntries = (0..<7).reversed().map { offset -> (date: String, level: String?) in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "M/d(E)"
            let record = emotionSnapshots.first { calendar.isDate($0.recordedAt, inSameDayAs: date) }
            return (date: formatter.string(from: date), level: record?.emotionLabel)
        }

        var weekdayBuckets: [Int: [String]] = [:]
        for snapshot in emotionSnapshots {
            let weekday = calendar.component(.weekday, from: snapshot.recordedAt) - 1
            weekdayBuckets[weekday, default: []].append(snapshot.emotionLabel)
        }
        let weekdayEntries = (0..<7).map { weekday -> (weekday: String, level: String?) in
            let labels = ["일","월","화","수","목","금","토"]
            let levels = weekdayBuckets[weekday] ?? []
            return (weekday: labels[weekday], level: levels.isEmpty ? nil : levels.last)
        }

        let titleResult        = try await AIService.shared.generateTitle(snapshots: emotionSnapshots)
        let linerResult        = try await AIService.shared.generateOneLiner(snapshots: emotionSnapshots)
        let summaryResult      = try await AIService.shared.generateWeeklySummary(snapshots: emotionSnapshots)
        let weeklyInsightResult  = try await AIService.shared.generateWeeklyInsight(entries: weeklyEntries)
        let weekdayInsightResult = try await AIService.shared.generateWeekdayInsight(entries: weekdayEntries)

        print("[ReportUseCase] titleResult: '\(titleResult)'")
        print("[ReportUseCase] linerResult: '\(linerResult)'")
        print("[ReportUseCase] summaryResult: '\(summaryResult)'")

        let todayTimeData = try await fetchDailyTimeEmotion(for: today, emotionSnapshots: emotionSnapshots)

        return ReportData(
            weekRange: weekRangeString(),
            summaryTitle: emotionSnapshots.isEmpty || titleResult.isEmpty ? "이번 주 감정 기록을 남겨보세요" : titleResult,
            summaryBody: emotionSnapshots.isEmpty || linerResult.isEmpty ? "기록이 쌓이면 변화를 확인할 수 있어요" : linerResult,
            aiSummary: emotionSnapshots.isEmpty || summaryResult.isEmpty ? "" : summaryResult,
            stats: ReportStats(recordedDays: 0, mostFrequentEmotion: "", lettersSent: 0),
            statusCards: [],
            weeklyChart: WeeklyEmotionChartData(entries: [], insight: weeklyInsightResult),
            dailyTimeData: todayTimeData,
            weekdayData: WeekdayEmotionData(entries: [], insight: weekdayInsightResult)
        )
    }

    func fetchDailyTimeEmotion(for date: Date, emotionSnapshots: [EmotionSnapshot]) async throws -> DailyTimeEmotionData {
        let calendar = Calendar.current
        let daySnapshots = emotionSnapshots.filter { calendar.isDate($0.recordedAt, inSameDayAs: date) }

        let slots: [TimeSlotEmotion] = TimeSlotEmotion.TimeSlot.allCases.map { slot in
            let matching = daySnapshots.filter { timeSlot(for: $0.recordedAt) == slot }
            let level = matching.last.flatMap { EmotionType(rawValue: $0.type) }.flatMap { emotionToLevel($0) }
            return TimeSlotEmotion(timeSlot: slot, level: level)
        }

        let timeEntries = slots.map { (timeSlot: $0.timeSlot.label, level: $0.level?.label) }
        let insight = try await AIService.shared.generateTimeInsight(entries: timeEntries)

        return DailyTimeEmotionData(date: date, slots: slots, insight: insight)
    }

    // MARK: - Private

    private func timeSlot(for date: Date) -> TimeSlotEmotion.TimeSlot {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<9:   return .morning
        case 9..<12:  return .forenoon
        case 12..<18: return .afternoon
        case 18..<22: return .evening
        default:      return .night
        }
    }

    private func emotionToLevel(_ type: EmotionType) -> EmotionLevel? {
        switch type {
        case .comfortable: return .relaxed
        case .stable:      return .stable
        case .normal:      return .normal
        case .frustrated:  return .frustrated
        case .depressed:   return .depressed
        }
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

struct EmotionSnapshot: Sendable, Equatable {
    let type: String
    let memo: String
    let recordedAt: Date

    var emotionLabel: String {
        EmotionType(rawValue: type)?.label ?? type
    }
}
