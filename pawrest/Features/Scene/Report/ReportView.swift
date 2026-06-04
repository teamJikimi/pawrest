//
//  ReportView.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import SwiftUI
import ComposableArchitecture

struct ReportView: View {
    let data: ReportData
    let store: StoreOf<NavigationBarReducer>

    @State private var selectedTab: ReportTab = .daily
    @State private var dailyTimeData: DailyTimeEmotionData

    init(data: ReportData, store: StoreOf<NavigationBarReducer>) {
        self.data = data
        self.store = store
        self._dailyTimeData = State(initialValue: data.dailyTimeData)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                dateHeader
                    .padding(.bottom, 20)
                summaryBanner
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                chartSection
                    .padding(.bottom, 20)
                aiSummarySection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                statsSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                diagnosticsSection
                    .padding(.bottom, 20)
                counselingSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
        }
        .customNavigationBar(store: store)
    }
}

private extension ReportView {
    var dateHeader: some View {
        Text(data.weekRange)
            .typography(.body2R1)
            .foregroundStyle(.gray80)
    }

    var summaryBanner: some View {
        HStack(spacing: 12) {
            Image(.systemIconDownChart)
                .resizable()
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text(data.summaryTitle)
                    .typography(.body2M)
                    .foregroundStyle(.gray80)
                Text(data.summaryBody)
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
            )
        )
        .cornerRadius(20, corners: .allCorners)
    }

    var chartSection: some View {
        VStack(spacing: 0) {
            chartTabBar
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            chartContent
        }
    }
    
    var chartTabBar: some View {
        SegmentTabBar(items: ReportTab.allCases, selection: $selectedTab)
    }

    @ViewBuilder
    var chartContent: some View {
        switch selectedTab {
        case .daily:
            EmotionLineChartCard(chartData: data.weeklyChart)
                .padding(.horizontal, 16)
        case .time:
            TimeEmotionChartCard(
                data: $dailyTimeData,
                onPrevious: { moveDateBy(-1) },
                onNext: { moveDateBy(1) }
            )
            .padding(.horizontal, 16)
        case .weekday:
            WeekdayEmotionChartCard(data: data.weekdayData)
                .padding(.horizontal, 16)
        }
    }

    var aiSummarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(.imageAi)
                Text("AI 감정 요약")
                    .typography(.body1M)
                    .foregroundStyle(.gray80)
            }
            Text(data.aiSummary)
                .typography(.body2R2)
                .foregroundStyle(.gray70)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray10)
        .cornerRadius(20, corners: .allCorners)
    }

    var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이번 주 함께한 순간들")
                .typography(.body1M)
                .foregroundStyle(.gray80)
            VStack(spacing: 6) {
                statRow(label: "감정 기록 일수", value: "\(data.stats.recordedDays)일", color: Color(.pawPrimary))
                statRow(label: "가장 많이 느낀 감정", value: data.stats.mostFrequentEmotion, color: .gray80)
                statRow(label: "하늘에 전달된 편지 수", value: "\(data.stats.lettersSent)통", color: Color(.accent))
            }
        }
        .padding(16)
        .background(.gray10)
        .cornerRadius(20, corners: .allCorners)
    }

    func statRow(label: String, value: String, color: Color?) -> some View {
        HStack {
            Text(label)
                .typography(.body3R)
                .foregroundStyle(.gray60)
            Spacer()
            Text(value)
                .typography(.body2M)
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
                    .typography(.date)
                    .foregroundStyle(.gray40)
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(data.statusCards) { card in
                        StatusCard(
                            title: card.title,
                            date: card.date,
                            score: card.score,
                            maxScore: card.maxScore,
                            previousScore: card.previousScore,
                            previousDate: card.previousDate,
                            scaleType: card.scaleType
                        )
                        .frame(width: 220)
                    }
                }
                .padding(.horizontal, 16)
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
                    .typography(.body4R)
                    .foregroundStyle(.gray60)
                    .lineSpacing(4)
            }
            counselingRow(name: "정신건강 위기상담전화", number: "1577-0199")
            counselingRow(name: "보건복지콜센터", number: "129")
        }
        .padding(16)
        .background(.rowMuted)
        .cornerRadius(20, corners: .allCorners)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray10, lineWidth: 1)
        )
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

    func moveDateBy(_ days: Int) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: days, to: dailyTimeData.date) else { return }
        dailyTimeData = DailyTimeEmotionData(date: newDate, slots: dailyTimeData.slots, insight: dailyTimeData.insight)
    }
}

// MARK: - ReportTab
enum ReportTab: String, CaseIterable, SegmentItem {
    case daily = "일별"
    case time = "시간대별"
    case weekday = "요일별"

    var title: String { rawValue }
}

#Preview {
    NavigationStack {
        ReportView(
            data: .mock,
            store: Store(
                initialState: NavigationBarState(title: "리포트"),
                reducer: { NavigationBarReducer() }
            )
        )
    }
}
