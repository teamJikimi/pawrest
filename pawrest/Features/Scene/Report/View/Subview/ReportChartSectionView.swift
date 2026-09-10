//
//  ReportChartSectionView.swift
//  pawrest
//
//  Created by 소은 on 9/3/26.
//

import SwiftUI

struct ReportChartSectionView: View {
    @Binding var selectedTab: ReportTab
    let weeklyChartData: WeeklyEmotionChartData
    let dailyTimeData: DailyTimeEmotionData
    let weekdayChartData: WeekdayEmotionData
    let onPreviousDay: () -> Void
    let onNextDay: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SegmentTabBar(items: ReportTab.allCases, selection: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            chartContent
        }
    }

    @ViewBuilder
    private var chartContent: some View {
        switch selectedTab {
        case .daily:
            EmotionLineChartCard(chartData: weeklyChartData)
                .padding(.horizontal, 20)
        case .time:
            TimeEmotionChartCard(
                data: Binding(get: { dailyTimeData }, set: { _ in }),
                onPrevious: onPreviousDay,
                onNext: onNextDay
            )
            .padding(.horizontal, 20)
        case .weekday:
            WeekdayEmotionChartCard(data: weekdayChartData)
                .padding(.horizontal, 20)
        }
    }
}
