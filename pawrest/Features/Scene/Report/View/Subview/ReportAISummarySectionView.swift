//
//  ReportAISummarySectionView.swift
//  pawrest
//
//  Created by 소은 on 9/3/26.
//

import SwiftUI

struct ReportAISummarySectionView: View {
    let data: ReportData
    let isAILoading: Bool
    let isAILoadFailed: Bool
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(.imageAi)
                Text("AI 감정 요약")
                    .typography(.body1M)
                    .foregroundStyle(.gray80)
            }
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray10)
        .cornerRadius(20, corners: .allCorners)
    }

    @ViewBuilder
    private var content: some View {
        if isAILoadFailed {
            failedState
        } else if isAILoading {
            loadingState
        } else {
            Text(data.aiSummary.isEmpty
                 ? "이번 주 감정 기록이 쌓이면\nAI가 감정을 분석해드려요."
                 : data.aiSummary)
                .typography(.body3R)
                .foregroundStyle(.gray60)
                .lineSpacing(4)
        }
    }

    private var failedState: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("AI 요약을 불러오지 못했어요")
                    .typography(.body2R2)
                    .foregroundStyle(.gray60)
                Text("잠시 후 다시 시도해 주세요")
                    .typography(.body3R)
                    .foregroundStyle(.gray40)
            }
            Button(action: onRetry) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.gray60)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var loadingState: some View {
        VStack(alignment: .leading, spacing: 8) {
            loadingText(width: .infinity)
            loadingText(width: .infinity)
            loadingText(width: 200)
        }
    }

    private func loadingText(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray20)
            .frame(maxWidth: width == .infinity ? .infinity : width, minHeight: 14, maxHeight: 14)
            .shimmer()
    }
}
