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

    @Query(sort: \AssessmentRecord.date, order: .reverse)
    private var assessmentRecords: [AssessmentRecord]

    @Query(sort: \EmotionRecordModel.recordedAt, order: .reverse)
    private var emotionRecords: [EmotionRecordModel]

    var currentDailyTimeData: DailyTimeEmotionData {
        let calendar = Calendar.current
        let date = store.dailyTimeData.date
        let dayRecords = emotionRecords.filter { calendar.isDate($0.recordedAt, inSameDayAs: date) }
        let slots = TimeSlotEmotion.TimeSlot.allCases.map { slot in
            let record = dayRecords.first { slot.contains(hour: calendar.component(.hour, from: $0.recordedAt)) }
            return TimeSlotEmotion(timeSlot: slot, level: record?.emotionTypeEnum?.toEmotionLevel)
        }
        return DailyTimeEmotionData(date: date, slots: slots, insight: nil)
    }

    var weekdayChartData: WeekdayEmotionData {
        let calendar = Calendar.current
        var buckets: [Int: [EmotionLevel]] = [:]
        for record in emotionRecords {
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
        return WeekdayEmotionData(entries: entries, insight: nil)
    }

    var weeklyChartData: WeeklyEmotionChartData {
        let calendar = Calendar.current
        let today = Date()
        let entries = (0..<7).reversed().map { offset -> WeeklyEmotionChartData.DailyEmotionEntry in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            let record = emotionRecords.first { calendar.isDate($0.recordedAt, inSameDayAs: date) }
            return .init(date: date, level: record?.emotionTypeEnum?.toEmotionLevel)
        }
        return WeeklyEmotionChartData(entries: entries, insight: nil)
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
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
            }
        }
        .customNavigationBar(store: store.scope(state: \.navigationBar, action: \.navigationBar))
        .onAppear { store.send(.onAppear) }
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
                Text(data.summaryTitle.isEmpty ? "이번 주 감정 기록을 남겨보세요" : data.summaryTitle)
                    .typography(.body2M)
                    .foregroundStyle(.gray80)
                Text(data.summaryBody.isEmpty ? "기록이 쌓이면 변화를 확인할 수 있어요" : data.summaryBody)
                    .typography(.body3R)
                    .foregroundStyle(.gray60)
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
            ))
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
            Text(data.aiSummary.isEmpty ? "이번 주 감정 기록이 쌓이면\nAI가 감정을 분석해드려요." : data.aiSummary)
                .typography(.body3R)
                .foregroundStyle(data.aiSummary.isEmpty ? .gray60 : .gray60)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray10)
        .cornerRadius(20, corners: .allCorners)
    }

    func statsSection(_ data: ReportData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이번 주 함께한 순간들")
                .typography(.body1M)
                .foregroundStyle(.gray80)
            VStack(spacing: 6) {
                statRow(label: "감정 기록 일수", value: "\(data.stats.recordedDays)일", color: Color(.pawPrimary))
                statRow(label: "가장 많이 느낀 감정", value: data.stats.mostFrequentEmotion, color: Color(.gray80))
                statRow(label: "하늘에 전달된 편지 수", value: "\(data.stats.lettersSent)통", color: Color(.accent))
            }
            
        }
        .padding(.vertical, 20)
        .padding(.horizontal,16)
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

#Preview {
    ReportView(
        store: Store(
            initialState: ReportFeature.State(),
            reducer: { ReportFeature() }
        )
    )
}
