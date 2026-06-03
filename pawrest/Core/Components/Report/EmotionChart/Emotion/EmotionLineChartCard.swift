//
//  EmotionLineChartCard.swift
//  pawrest
//
//  Created by 소은 on 6/1/26.
//

import SwiftUI

struct EmotionLineChartCard: View {
    let chartData: WeeklyEmotionChartData

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.bottom, 32)
            content
        }
        .padding(16)
        .background(.gray0)
        .cornerRadius(20, corners: .allCorners)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.gray10, lineWidth: 1)
        )
        .frame(height: chartData.hasData ? nil : 329)
    }
}

private extension EmotionLineChartCard {
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(.imageCalendar)
                    .resizable()
                    .frame(width: 14, height: 14)
                Text("일별 감정 변화")
                    .typography(.body1M)
                    .foregroundColor(.primary)
            }
            Text("이번 주 날짜별 감정 추이")
                .typography(.date)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    var content: some View {
        if chartData.hasData {
            EmotionLineChart(entries: chartData.entries)
            if let insight = chartData.insight {
                InsightBox(text: insight)
                    .padding(.top, 20)
            }
        } else {
            EmotionEmptyState()
        }
    }
}
