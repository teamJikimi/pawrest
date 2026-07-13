//
//  StatusCard.swift
//  pawrest
//
//  Created by 소은 on 5/31/26.
//

import SwiftUI

struct StatusCard: View {
    let title: String
    let date: String
    let score: Int
    let maxScore: Int
    let previousScore: Int?
    let previousDate: Date?
    let scaleType: ScaleType

    private var riskLevel: RiskLevel {
        scaleType.riskLevel(for: score)
    }

    private var progress: Double {
        guard maxScore > 0 else { return 0 }
        return min(Double(score) / Double(maxScore), 1.0)
    }

    private var scoreDelta: Int {
        guard let previousScore else { return 0 }
        return score - previousScore
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow
            scoreRow
            progressBar
            Divider()
            previousScoreRow
        }
        .padding(20)
        .background(.gray0)
        .cornerRadius(16, corners: .allCorners)
    }
}

// MARK: - Subviews

private extension StatusCard {
    var headerRow: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .typography(.body2M)
                    .foregroundStyle(.gray80)
                Text(date)
                    .typography(.date)
                    .foregroundStyle(.gray50)
            }
            Spacer()
            RiskBadge(level: riskLevel)
        }
    }

    var scoreRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Spacer()
            Text("\(score)")
                .typography(.body1M)
                .foregroundStyle(riskLevel.color)
                .contentTransition(.numericText())
            Text("/ \(maxScore)")
                .typography(.date)
                .foregroundStyle(.gray50)
        }
    }

    var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.gray30)
                    .frame(height: 8)
                Capsule()
                    .fill(riskLevel.color)
                    .frame(width: geo.size.width * progress, height: 8)
            }
        }
        .frame(height: 10)
    }

    var previousScoreRow: some View {
        HStack {
            Text("이전 검사")
                .typography(.date)
                .foregroundStyle(.gray60)
            if let previousDate {
                Text(previousDate.formattedRelative)
                    .typography(.date)
                    .foregroundStyle(.gray40)
            }
            Spacer()
            if let _ = previousDate {
                DeltaBadge(delta: scoreDelta)
            } else {
                Text("기록 없음")
                    .typography(.date)
                    .foregroundStyle(.gray60)
            }
        }
    }
}
