//
//  ReportUseCase.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import Foundation
import SwiftData

protocol ReportUseCaseProtocol {
    func buildLocalData() -> ReportData
    func fetchAIData(emotionSnapshots: [EmotionSnapshot], context: ModelContext) async throws -> (AIReportResult, String?, DailyTimeEmotionData)
    func fetchDailyTimeEmotion(for date: Date, emotionSnapshots: [EmotionSnapshot]) async throws -> DailyTimeEmotionData
}

struct EmotionSnapshot: Sendable, Equatable {
    let type: String
    let memo: String
    let recordedAt: Date

    var emotionLabel: String {
        EmotionType(rawValue: type)?.label ?? type
    }
}

struct ReportUseCase: ReportUseCaseProtocol {

    // 로컬 데이터만 즉시 반환 (AI 없음)
    func buildLocalData() -> ReportData {
        ReportData(
            weekRange: weekRangeString(),
            summaryTitle: "이번 주 감정 기록을 남겨보세요",
            summaryBody: "기록이 쌓이면 변화를 확인할 수 있어요",
            aiSummary: "",
            stats: ReportStats(recordedDays: 0, mostFrequentEmotion: "", lettersSent: 0),
            statusCards: [],
            weeklyChart: WeeklyEmotionChartData(entries: [], insight: nil),
            dailyTimeData: DailyTimeEmotionData(date: Date(), slots: [], insight: nil),
            weekdayData: WeekdayEmotionData(entries: [], insight: nil)
        )
    }

    // AI 호출 (캐시 확인 포함)
    func fetchAIData(emotionSnapshots: [EmotionSnapshot], context: ModelContext) async throws -> (AIReportResult, String?, DailyTimeEmotionData) {
        let calendar = Calendar.current
        let today = Date()

        let weekEnd = weekEndDate(from: today)
        let hash = snapshotHash(emotionSnapshots)
        let descriptor = FetchDescriptor<WeeklyReportCache>(
            predicate: #Predicate { $0.weekEndDate == weekEnd && $0.snapshotHash == hash }
        )
        if let cached = try? context.fetch(descriptor).first {
            print("[ReportUseCase] 캐시 히트")
            let todayTimeData = try await fetchDailyTimeEmotion(for: today, emotionSnapshots: emotionSnapshots, cachedInsight: cached.timeInsight)
            let aiResult = AIReportResult(
                bannerTitle: cached.summaryTitle,
                bannerSummary: cached.summaryBody,
                weeklySummary: cached.aiSummary,
                dailyInsight: cached.weeklyInsight
            )
            return (aiResult, cached.weekdayInsight, todayTimeData)
        }

        print("[ReportUseCase] 캐시 미스 — AI 호출")

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

        let aiResult      = try await AIService.shared.generateReport(snapshots: emotionSnapshots, weeklyEntries: weeklyEntries)
        let weekdayInsight = try await AIService.shared.generateWeekdayInsight(entries: weekdayEntries)
        let todayTimeData  = try await fetchDailyTimeEmotion(for: today, emotionSnapshots: emotionSnapshots)

        let cache = WeeklyReportCache(
            weekEndDate: weekEnd,
            snapshotHash: hash,
            summaryTitle: aiResult.bannerTitle,
            summaryBody: aiResult.bannerSummary,
            aiSummary: aiResult.weeklySummary,
            weeklyInsight: aiResult.dailyInsight,
            weekdayInsight: weekdayInsight,
            timeInsight: todayTimeData.insight
        )
        context.insert(cache)
        try? context.save()

        return (aiResult, weekdayInsight, todayTimeData)
    }

    func fetchDailyTimeEmotion(for date: Date, emotionSnapshots: [EmotionSnapshot]) async throws -> DailyTimeEmotionData {
        return try await fetchDailyTimeEmotion(for: date, emotionSnapshots: emotionSnapshots, cachedInsight: nil)
    }

    private func fetchDailyTimeEmotion(for date: Date, emotionSnapshots: [EmotionSnapshot], cachedInsight: String?) async throws -> DailyTimeEmotionData {
        let calendar = Calendar.current
        let daySnapshots = emotionSnapshots.filter { calendar.isDate($0.recordedAt, inSameDayAs: date) }

        let slots: [TimeSlotEmotion] = TimeSlotEmotion.TimeSlot.allCases.map { slot in
            let matching = daySnapshots.filter { timeSlot(for: $0.recordedAt) == slot }
            let level = matching.last.flatMap { EmotionType(rawValue: $0.type) }.flatMap { emotionToLevel($0) }
            return TimeSlotEmotion(timeSlot: slot, level: level)
        }

        let insight: String?
        if let cached = cachedInsight {
            insight = cached
        } else {
            let timeEntries = slots.map { (timeSlot: $0.timeSlot.label, level: $0.level?.label) }
            insight = try await AIService.shared.generateTimeInsight(entries: timeEntries)
        }

        return DailyTimeEmotionData(date: date, slots: slots, insight: insight)
    }

    // MARK: - Private

    private func snapshotHash(_ snapshots: [EmotionSnapshot]) -> String {
        let key = snapshots.map { "\($0.type)\($0.recordedAt.timeIntervalSince1970)" }.joined()
        return String(key.hashValue)
    }

    private func weekEndDate(from date: Date) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let daysToSunday = (8 - weekday) % 7
        let sunday = calendar.date(byAdding: .day, value: daysToSunday, to: date)!
        return calendar.startOfDay(for: sunday)
    }

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
