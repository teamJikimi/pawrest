//
//  WeekdayEmotionChartCard.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import SwiftUI

struct WeekdayEmotionChartCard: View {
    let data: WeekdayEmotionData

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.bottom, 32)
            content
        }
        .padding(16)
        .background(.gray0)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.gray10, lineWidth: 1)
        )
        .frame(height: data.hasData ? nil : 329)
    }
}

private extension WeekdayEmotionChartCard {
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(.imageSecondaryCalendar)
                    .resizable()
                    .frame(width: 14, height: 14)
                Text("요일별 감정 패턴")
                    .typography(.body1M)
                    .foregroundColor(.primary)
            }
            Text("여러 주간 요일별 평균")
                .typography(.date)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    var content: some View {
        if data.hasData {
            WeekdayEmotionBarChart(entries: data.entries)
            if let insight = data.insight {
                InsightBox(text: insight)
                    .padding(.top, 20)
            }
        } else {
            EmotionEmptyState()
        }
    }
}

#Preview("데이터 있음") {
    WeekdayEmotionChartCard(data: .mock)
        .padding()
}

#Preview("데이터 없음") {
    WeekdayEmotionChartCard(data: .empty)
        .padding()
}
