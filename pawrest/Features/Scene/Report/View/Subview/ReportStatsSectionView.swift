//
//  ReportStatsSectionView.swift
//  pawrest
//
//  Created by 소은 on 9/3/26.
//

import SwiftUI

struct ReportStatsSectionView: View {
    let data: ReportData
    let deliveredLetterCount: Int

    var body: some View {
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

    private func statRow(label: String, value: String, color: Color?) -> some View {
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
}
