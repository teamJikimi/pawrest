//
//  ReportUseCase.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import Foundation
import SwiftData

protocol ReportUseCaseProtocol {
    func buildLocalData(snapshots: [EmotionSnapshot]) -> ReportData
    func fetchAIData(emotionSnapshots: [EmotionSnapshot], container: ModelContainer) async throws -> (AIReportResult, String?, DailyTimeEmotionData)
    func fetchDailyTimeEmotion(for date: Date, emotionSnapshots: [EmotionSnapshot]) async throws -> DailyTimeEmotionData
}

// MARK: - EmotionSnapshot

struct EmotionSnapshot: Sendable, Equatable {
    let type: String
    let memo: String
    let recordedAt: Date

    var emotionLabel: String {
        EmotionType(rawValue: type)?.label ?? type
    }
}

// MARK: - ReportUseCase

struct ReportUseCase: ReportUseCaseProtocol {

    func buildLocalData(snapshots: [EmotionSnapshot] = []) -> ReportData {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(byAdding: .day, value: -6, to: today)!

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        let rangeText = "\(formatter.string(from: weekStart)) - \(formatter.string(from: today)), \(calendar.component(.year, from: today))"

        let weekSnapshots = snapshots.filter { $0.recordedAt >= weekStart }

        let recordedDays = Set(weekSnapshots.map { calendar.startOfDay(for: $0.recordedAt) }).count

        let mostFrequent = weekSnapshots
            .compactMap { EmotionType(rawValue: $0.type)?.label }
            .reduce(into: [String: Int]()) { $0[$1, default: 0] += 1 }
            .max(by: { $0.value < $1.value })?.key ?? "-"

        return ReportData(
            weekRange: rangeText,
            summaryTitle: "AI분석에 실패 했어요",
            summaryBody: "잠시뒤에 다시 시도해주세요",
            aiSummary: "AI가 이번 주 감정 흐름을 분석 중이에요.\n잠시만 기다려주세요.",
            stats: ReportStats(
                recordedDays: recordedDays,
                mostFrequentEmotion: mostFrequent,
                lettersSent: 0
            ),
            statusCards: [],
            weeklyChart: .empty,
            dailyTimeData: .empty,
            weekdayData: .empty
        )
    }

    func fetchAIData(
        emotionSnapshots: [EmotionSnapshot],
        container: ModelContainer
    ) async throws -> (AIReportResult, String?, DailyTimeEmotionData) {
        let context = ModelContext(container)
        let hash = snapshotHash(emotionSnapshots)
        let weekEndDate = Calendar.current.startOfDay(for: Date())

        let descriptor = FetchDescriptor<WeeklyReportCache>(
            predicate: #Predicate { $0.weekEndDate == weekEndDate && $0.snapshotHash == hash }
        )
        if let cached = try? context.fetch(descriptor).first {
            let aiResult = AIReportResult(
                bannerTitle: cached.summaryTitle,
                bannerSummary: cached.summaryBody,
                weeklySummary: cached.aiSummary,
                dailyInsight: cached.weeklyInsight
            )
            let todayTime = await buildTimeData(for: Date(), snapshots: emotionSnapshots, timeInsight: cached.timeInsight)
            return (aiResult, cached.weekdayInsight, todayTime)
        }

        let weeklyEntries = makeWeeklyEntries(snapshots: emotionSnapshots)
        let aiResult = try await AIService.shared.generateReport(
            snapshots: emotionSnapshots,
            weeklyEntries: weeklyEntries
        )

        let weekdayEntries = makeWeekdayEntries(snapshots: emotionSnapshots)
        let weekdayInsight = try? await AIService.shared.generateWeekdayInsight(entries: weekdayEntries)

        let todaySlots = makeTimeSlots(for: Date(), snapshots: emotionSnapshots)
        let timeEntries = todaySlots.map { (timeSlot: $0.timeSlot.label, level: $0.level?.label) }
        let timeInsight = try? await AIService.shared.generateTimeInsight(entries: timeEntries)

        let todayTime = DailyTimeEmotionData(date: Date(), slots: todaySlots, insight: timeInsight)

        let cache = WeeklyReportCache(
            weekEndDate: weekEndDate,
            snapshotHash: hash,
            summaryTitle: aiResult.bannerTitle,
            summaryBody: aiResult.bannerSummary,
            aiSummary: aiResult.weeklySummary,
            weeklyInsight: aiResult.dailyInsight,
            weekdayInsight: weekdayInsight,
            timeInsight: timeInsight
        )
        context.insert(cache)
        try? context.save()

        return (aiResult, weekdayInsight, todayTime)
    }

    func fetchDailyTimeEmotion(for date: Date, emotionSnapshots: [EmotionSnapshot]) async throws -> DailyTimeEmotionData {
        let slots = makeTimeSlots(for: date, snapshots: emotionSnapshots)
        let timeEntries = slots.map { (timeSlot: $0.timeSlot.label, level: $0.level?.label) }
        let insight = try? await AIService.shared.generateTimeInsight(entries: timeEntries)
        return DailyTimeEmotionData(date: date, slots: slots, insight: insight)
    }
}

// MARK: - Private Helpers

private extension ReportUseCase {

    func snapshotHash(_ snapshots: [EmotionSnapshot]) -> String {
        let joined = snapshots.map { "\($0.type)-\($0.recordedAt.timeIntervalSince1970)" }.joined(separator: "|")
        return String(joined.hashValue)
    }

    func makeWeeklyEntries(snapshots: [EmotionSnapshot]) -> [(date: String, level: String?)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return (0..<7).map { offset -> (date: String, level: String?) in
            let date = calendar.date(byAdding: .day, value: offset - 6, to: today)!
            let dayLabel = String(formatter.string(from: date).prefix(1))
            let level = snapshots
                .filter { calendar.isDate($0.recordedAt, inSameDayAs: date) }
                .compactMap { EmotionType(rawValue: $0.type)?.label }
                .last
            return (date: dayLabel, level: level)
        }
    }

    func makeWeekdayEntries(snapshots: [EmotionSnapshot]) -> [(weekday: String, level: String?)] {
        let calendar = Calendar.current
        let weekdayLabels = ["일", "월", "화", "수", "목", "금", "토"]
        return (1...7).map { weekday -> (weekday: String, level: String?) in
            let level = snapshots
                .filter { calendar.component(.weekday, from: $0.recordedAt) == weekday }
                .compactMap { EmotionType(rawValue: $0.type)?.label }
                .last
            return (weekday: weekdayLabels[weekday - 1], level: level)
        }
    }

    func makeTimeSlots(for date: Date, snapshots: [EmotionSnapshot]) -> [TimeSlotEmotion] {
        let calendar = Calendar.current
        let daySnapshots = snapshots.filter { calendar.isDate($0.recordedAt, inSameDayAs: date) }
        return TimeSlotEmotion.TimeSlot.allCases.map { slot in
            let level = daySnapshots
                .filter { timeSlot(for: $0.recordedAt) == slot }
                .compactMap { EmotionType(rawValue: $0.type).flatMap { emotionToLevel($0) } }
                .last
            return TimeSlotEmotion(timeSlot: slot, level: level)
        }
    }

    func timeSlot(for date: Date) -> TimeSlotEmotion.TimeSlot {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<9:   return .morning
        case 9..<12:  return .forenoon
        case 12..<17: return .afternoon
        case 17..<21: return .evening
        default:      return .night
        }
    }

    func emotionToLevel(_ type: EmotionType) -> EmotionLevel {
        switch type {
        case .comfortable: return .relaxed
        case .stable:      return .stable
        case .normal:      return .normal
        case .frustrated:  return .frustrated
        case .depressed:   return .depressed
        }
    }

    func buildTimeData(for date: Date, snapshots: [EmotionSnapshot], timeInsight: String?) async -> DailyTimeEmotionData {
        let slots = makeTimeSlots(for: date, snapshots: snapshots)
        return DailyTimeEmotionData(date: date, slots: slots, insight: timeInsight)
    }
}
