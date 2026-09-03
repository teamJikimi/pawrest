//
//  ReportSummaryBannerView.swift
//  pawrest
//
//  Created by 소은 on 9/3/26.
//

import SwiftUI

struct ReportSummaryBannerView: View {
    let data: ReportData
    let isAILoading: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(.systemIconDownChart)
                .resizable()
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 4) {
                if isAILoading {
                    loadingText(width: 120)
                    loadingText(width: 180)
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

    private func loadingText(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray20)
            .frame(maxWidth: width, minHeight: 14, maxHeight: 14)
            .shimmer()
    }
}
