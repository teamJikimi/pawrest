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

    var deliveredLetterCount: Int {
        letters.filter { $0.sentAt.addingTimeInterval(deliveryInterval) <= Date() }.count
    }

    var currentDailyTimeData: DailyTimeEmotionData {
        let calendar = Calendar.current
        let date = store.dailyTimeData.date
        let dayRecords = emotionRecords.filter { calendar.isDate($0.recordedAt, inSameDayAs: date) }
        let slots = TimeSlotEmotion.TimeSlot.allCases.map { slot in
            let record = dayRecords.first { slot.contains(hour: calendar.component(.hour, from: $0.recordedAt)) }
            return TimeSlotEmotion(timeSlot: slot, level: record?.emotionTypeEnum?.toEmotionLevel)
        }
        return DailyTimeEmotionData(date: date, slots: slots, insight: store.dailyTimeData.insight)
    }

    var weekdayChartData: WeekdayEmotionData {
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

    var weeklyChartData: WeeklyEmotionChartData {
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
                    dateHeader(data)
                        .padding(.bottom, 20)
                    summaryBanner(data)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    chartSection(data)
                        .padding(.bottom, 20)
                    aiSummarySection(data)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    statsSection(data)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    diagnosticsSection
                        .padding(.bottom, 20)
                    counselingSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            } else if store.isLoading {
                LoadingView()
            }
        }
        .customNavigationBar(store: store.scope(state: \.navigationBar, action: \.navigationBar))
        .onAppear {
            let today = Calendar.current.startOfDay(for: Date())
            let snapshots = emotionRecords
                .filter { $0.recordedAt < today }
                .map { EmotionSnapshot(type: $0.emotionType, memo: $0.memo, recordedAt: $0.recordedAt) }
            store.send(.onAppear(snapshots: snapshots, context: modelContext))
        }
        .hideTabBar()
    }
}

private extension ReportView {

    func dateHeader(_ data: ReportData) -> some View {
        Text(data.weekRange)
            .typography(.body2R1)
            .foregroundStyle(.gray80)
    }

    func summaryBanner(_ data: ReportData) -> some View {
        HStack(spacing: 12) {
            Image(.systemIconDownChart)
                .resizable()
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 4) {
                if store.isAILoading {
                    aiLoadingText(width: 120)
                    aiLoadingText(width: 180)
                } else {
                    Text(data.summaryTitle)
                        .typography(.body2M)
                        .foregroundStyle(.gray80)
                    if !data.summaryBody.isEmpty {
                        Text(data.summaryBody)
                            .typography(.body3R)
                            .foregroundStyle(.gray60)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(
            LinearGradient(
                colors: [.white, .primaryLight],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.gray10, lineWidth: 1)
        )
    }

    func chartSection(_ data: ReportData) -> some View {
        VStack(spacing: 0) {
            SegmentTabBar(items: ReportTab.allCases, selection: $store.selectedTab.sending(\.tabChanged))
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            chartContent(data)
        }
    }

    @ViewBuilder
    func chartContent(_ data: ReportData) -> some View {
        switch store.selectedTab {
        case .daily:
            EmotionLineChartCard(chartData: weeklyChartData)
                .padding(.horizontal, 16)
        case .time:
            TimeEmotionChartCard(
                data: Binding(
                    get: { currentDailyTimeData },
                    set: { _ in }
                ),
                onPrevious: { store.send(.previousDayTapped) },
                onNext: { store.send(.nextDayTapped) }
            )
            .padding(.horizontal, 16)
        case .weekday:
            WeekdayEmotionChartCard(data: weekdayChartData)
                .padding(.horizontal, 16)
        }
    }

    func aiSummarySection(_ data: ReportData) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(.imageAi)
                Text("AI 감정 요약")
                    .typography(.body1M)
                    .foregroundStyle(.gray80)
            }
            if store.isAILoadFailed {
                VStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("AI 요약을 불러오지 못했어요")
                            .typography(.body2R2)
                            .foregroundStyle(.gray60)
                        Text("잠시 후 다시 시도해 주세요")
                            .typography(.body3R)
                            .foregroundStyle(.gray40)
                    }
                    Button {
                        let today = Calendar.current.startOfDay(for: Date())
                        let snapshots = emotionRecords
                            .filter { $0.recordedAt < today }
                            .map { EmotionSnapshot(type: $0.emotionType, memo: $0.memo, recordedAt: $0.recordedAt) }
                        store.send(.onAppear(snapshots: snapshots, context: modelContext))
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.gray60)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } else if store.isAILoading {
                VStack(alignment: .leading, spacing: 8) {
                    aiLoadingText(width: .infinity)
                    aiLoadingText(width: .infinity)
                    aiLoadingText(width: 200)
                }
            } else {
                Text(data.aiSummary.isEmpty ? "이번 주 감정 기록이 쌓이면\nAI가 감정을 분석해드려요." : data.aiSummary)
                    .typography(.body3R)
                    .foregroundStyle(.gray60)
                    .lineSpacing(4)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray10)
        .cornerRadius(20, corners: .allCorners)
    }

    @ViewBuilder
    func aiLoadingText(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray20)
            .frame(maxWidth: width == .infinity ? .infinity : width, minHeight: 14, maxHeight: 14)
            .shimmer()
    }

    func statsSection(_ data: ReportData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이번 주 함께한 순간들")
                .typography(.body1M)
                .foregroundStyle(.gray80)
            VStack(spacing: 6) {
                statRow(label: "감정 기록 일수", value: "\(data.stats.recordedDays)일", color: Color(.pawPrimary))
                statRow(label: "가장 많이 느낀 감정", value: data.stats.mostFrequentEmotion, color: Color(.gray80))
                statRow(label: "하늘에 전달된 편지 수", value: "\(deliveredLetterCount)통", color: Color(.accent))
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.gray10)
        .cornerRadius(20, corners: .allCorners)
    }

    func statRow(label: String, value: String, color: Color?) -> some View {
        HStack {
            Text(label)
                .typography(.body2R1)
                .foregroundStyle(.gray60)
            Spacer()
            Text(value)
                .typography(.body2Accent)
                .foregroundStyle(color ?? Color(.gray80))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
        .background(.gray0)
        .cornerRadius(10, corners: .allCorners)
    }

    var diagnosticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("자가진단 검사 기록")
                    .typography(.body1M)
                    .foregroundStyle(.gray80)
                Text("의학적 진단이 아닌 참고 지표에요")
                    .typography(.caption)
                    .foregroundStyle(.gray60)
                    .padding(.bottom, 6)
            }
            .padding(.leading, 36)
            .padding(.bottom, 12)

            if assessmentRecords.isEmpty {
                Text("아직 검사 기록이 없어요")
                    .typography(.body3R)
                    .foregroundStyle(.gray40)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(assessmentRecords) { record in
                            if let type = record.type {
                                let previousRecord = assessmentRecords
                                    .filter { $0.typeRawValue == record.typeRawValue && $0.date < record.date }
                                    .first
                                StatusCard(
                                    title: type.title,
                                    date: record.date,
                                    score: record.totalScore,
                                    maxScore: type.toScaleType.maxScore,
                                    previousScore: previousRecord?.totalScore,
                                    previousDate: previousRecord?.date,
                                    scaleType: type.toScaleType
                                )
                                .frame(width: 260, height: 175)
                                .clipped()
                            }
                        }
                    }
                    .padding(.leading, 36)
                    .padding(.bottom, 20)
                }
                .frame(height: 164)
                .scrollContentBackground(.hidden)
            }
        }
        .padding(.vertical, 16)
        .background(.gray10)
    }

    var counselingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(uiImage: .imagePlus)
                        .resizable()
                        .frame(width: 14, height: 14)
                    Text("전문 상담기관 안내")
                        .typography(.body1M)
                        .foregroundStyle(.gray80)
                }
                Text("많은 분들이 전문 상담으로 마음의 짐을 덜었어요\n힘들 땐 전문 상담기관을 찾아보는 건 어떨까요?")
                    .typography(.caption)
                    .foregroundStyle(.gray60)
                    .lineSpacing(4)
                    .padding(.top, 2)
            }
            counselingRow(name: "정신건강 위기상담전화", number: "1577-0199")
            counselingRow(name: "보건복지콜센터", number: "129")
        }
        .padding(16)
        .background(.rowMuted)
        .cornerRadius(20, corners: .allCorners)
    }

    func counselingRow(name: String, number: String) -> some View {
        HStack {
            Text(name)
                .typography(.body3R)
                .foregroundStyle(.gray80)
            Spacer()
            Text(number)
                .typography(.body3R)
                .foregroundStyle(.gray80)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(.gray20)
        .cornerRadius(10, corners: .allCorners)
    }
}
