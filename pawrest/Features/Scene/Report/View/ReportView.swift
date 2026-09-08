//
//  ReportView.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct ReportView: View {
    @Bindable var store: StoreOf<ReportFeature>
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \AssessmentRecord.date, order: .reverse)
    private var assessmentRecords: [AssessmentRecord]

    @Query(sort: \EmotionRecordModel.recordedAt, order: .reverse)
    private var emotionRecords: [EmotionRecordModel]

    @Query(sort: \LetterModel.sentAt)
    private var letters: [LetterModel]

    private let deliveryInterval: TimeInterval = 24 * 60 * 60

    private var riskDetector: EmotionRiskDetector {
        EmotionRiskDetector(records: emotionRecords)
    }

    private var deliveredLetterCount: Int {
        letters.filter { $0.sentAt.addingTimeInterval(deliveryInterval) <= Date() }.count
    }

    private var currentDailyTimeData: DailyTimeEmotionData {
        let calendar = Calendar.current
        let date = store.dailyTimeData.date
        let dayRecords = emotionRecords.filter { calendar.isDate($0.recordedAt, inSameDayAs: date) }
        let slots = TimeSlotEmotion.TimeSlot.allCases.map { slot in
            let record = dayRecords.first { slot.contains(hour: calendar.component(.hour, from: $0.recordedAt)) }
            return TimeSlotEmotion(timeSlot: slot, level: record?.emotionTypeEnum?.toEmotionLevel)
        }
        return DailyTimeEmotionData(date: date, slots: slots, insight: store.dailyTimeData.insight)
    }

    private var weekdayChartData: WeekdayEmotionData {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var buckets: [Int: [EmotionLevel]] = [:]
        for record in emotionRecords {
            guard record.recordedAt < today else { continue }
            let weekday = calendar.component(.weekday, from: record.recordedAt) - 1
            if let level = record.emotionTypeEnum?.toEmotionLevel {
                buckets[weekday, default: []].append(level)
            }
        }
        let entries = (0..<7).map { weekday -> WeekdayEmotionData.WeekdayEntry in
            let levels = buckets[weekday] ?? []
            let avg = levels.isEmpty ? nil : EmotionLevel(rawValue: levels.map(\.rawValue).reduce(0, +) / levels.count)
            return WeekdayEmotionData.WeekdayEntry(weekday: weekday, level: avg)
        }
        return WeekdayEmotionData(entries: entries, insight: store.reportData?.weekdayData.insight)
    }

    private var weeklyChartData: WeeklyEmotionChartData {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let entries = (0..<7).reversed().map { offset -> WeeklyEmotionChartData.DailyEmotionEntry in
            let date = calendar.date(byAdding: .day, value: -offset, to: yesterday)!
            let record = emotionRecords.first { calendar.isDate($0.recordedAt, inSameDayAs: date) }
            return .init(date: date, level: record?.emotionTypeEnum?.toEmotionLevel)
        }
        return WeeklyEmotionChartData(entries: entries, insight: store.reportData?.weeklyChart.insight)
    }

    var body: some View {
        ScrollView {
            if let data = store.reportData {
                VStack(spacing: 0) {
                    Text(data.weekRange)
                        .typography(.body2R1)
                        .foregroundStyle(.gray80)
                        .padding(.bottom, 20)

                    ReportSummaryBannerView(data: data, isAILoading: store.isAILoading)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)

                    ReportChartSectionView(
                        selectedTab: $store.selectedTab.sending(\.tabChanged),
                        weeklyChartData: weeklyChartData,
                        dailyTimeData: currentDailyTimeData,
                        weekdayChartData: weekdayChartData,
                        onPreviousDay: { store.send(.previousDayTapped) },
                        onNextDay: { store.send(.nextDayTapped) }
                    )
                    .padding(.bottom, 20)

                    ReportAISummarySectionView(
                        data: data,
                        isAILoading: store.isAILoading,
                        isAILoadFailed: store.isAILoadFailed,
                        onRetry: sendOnAppear
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                    ReportStatsSectionView(data: data, deliveredLetterCount: deliveredLetterCount)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    ReportDiagnosticsSectionView(assessmentRecords: assessmentRecords)
                        .padding(.bottom, 20)

                    if riskDetector.shouldShowCounselingBanner {
                        ReportCounselingSectionView()
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                    }
                }
            } else if store.isLoading {
                LoadingView()
            }
        }
        .customNavigationBar(store: store.scope(state: \.navigationBar, action: \.navigationBar))
        .onAppear { sendOnAppear() }
        .hideTabBar()
    }

    private func sendOnAppear() {
        let today = Calendar.current.startOfDay(for: Date())
        let snapshots = emotionRecords
            .filter { $0.recordedAt < today }
            .map { EmotionSnapshot(type: $0.emotionType, memo: $0.memo, recordedAt: $0.recordedAt) }
        store.send(.onAppear(
            snapshots: snapshots,
            assessmentRecords: Array(assessmentRecords),
            context: modelContext
        ))
    }
}
