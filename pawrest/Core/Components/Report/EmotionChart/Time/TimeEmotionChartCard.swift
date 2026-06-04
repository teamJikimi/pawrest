//
//  TimeEmotionChartCard.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import SwiftUI

struct TimeEmotionChartCard: View {
    @Binding var data: DailyTimeEmotionData

    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.bottom, 32)
            dateNavigator
                .padding(.bottom, 23)
            content
        }
        .padding(16)
        .background(.gray0)
        .cornerRadius(20, corners: .allCorners)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.gray10, lineWidth: 1)
        )
        .frame(height: data.hasData ? nil : 329)
    }
}

private extension TimeEmotionChartCard {
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(.imageClock)
                    .resizable()
                    .frame(width: 14, height: 14)
                Text("시간대별 감정 패턴")
                    .typography(.body1M)
                    .foregroundColor(.primary)
            }
            Text("이번 주 시간대별 감정 추이")
                .typography(.date)
                .foregroundColor(.secondary)
        }
    }

    var dateNavigator: some View {
        HStack {
            Button(action: onPrevious) {
                Image(.iconBack)
                    .resizable()
                    .frame(width: 18, height: 18)
            }
            Spacer()
            Text(data.dateLabel)
                .typography(.body2R1)
                .foregroundColor(.primary)
            Spacer()
            Button(action: onNext) {
                Image(.iconBack)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 18, height: 18)
                    .scaleEffect(x: -1)
                    .foregroundStyle(isToday ? .gray40 : .gray80)
            }
            .disabled(isToday)
        }
        .padding(.horizontal, 4)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(data.date)
    }
    
    @ViewBuilder
    var content: some View {
        if data.hasData {
            TimeEmotionBarChart(slots: data.slots)
            if let insight = data.insight {
                InsightBox(text: insight)
                    .padding(.top, 20)
            }
        } else {
            EmotionEmptyState()
        }
    }
}
