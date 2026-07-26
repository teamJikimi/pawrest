
//
//  Untitled.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import SwiftUI

struct EmotionChartScrollView: View {
    let weeklyData: WeeklyEmotionChartData
    let weekdayData: WeekdayEmotionData

    @State private var dailyData: DailyTimeEmotionData = .mock

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                EmotionLineChartCard(chartData: weeklyData)
                    .containerRelativeFrame(.horizontal)
                TimeEmotionChartCard(
                    data: $dailyData,
                    onPrevious: { moveDateBy(-1) },
                    onNext: { moveDateBy(1) }
                )
                .containerRelativeFrame(.horizontal)
                WeekdayEmotionChartCard(data: weekdayData)
                    .containerRelativeFrame(.horizontal)
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .padding(.horizontal, 16)
    }

    private func moveDateBy(_ days: Int) {
        guard let newDate = Calendar.current.date(
            byAdding: .day,
            value: days,
            to: dailyData.date
        ) else { return }
        dailyData = DailyTimeEmotionData(
            date: newDate,
            slots: dailyData.slots,
            insight: dailyData.insight
        )
    }
}
