//
//  SelfAssessmentResultView.swift
//  pawrest
//
//  Created by 소은 on 6/14/26.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct SelfAssessmentResultView: View {
    @Bindable var store: StoreOf<SelfAssessmentResultFeature>
    @State private var cardHeight: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
            scoreCard
            if cardHeight > 0 { scrollContent }
        }
        .background(.gray0)
        .customNavigationBar(
            store: store.scope(state: \.navBar, action: \.navBar)
        )
    }
}

// MARK: - Subviews

private extension SelfAssessmentResultView {

    var scoreCard: some View {
        ScoreCardView(
            title: store.testTitle,
            score: store.score,
            maxScore: store.maxScore,
            level: store.scoreLevel
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { cardHeight = geo.size.height }
            }
        )
        .zIndex(0)
    }

    var scrollContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                Color.clear.frame(height: cardHeight + 16)
                bottomSheet
            }
        }
        .zIndex(1)
    }

    var bottomSheet: some View {
        VStack(spacing: 12) {
            handle
            AssessmentInterpretationSection(
                rows: store.interpretationRows,
                currentLevel: store.scoreLevel
            )
            AssessmentHistorySection(historyState: store.historyState)
            noticeSection
            sourceSection
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity)
        .background(
            Color.gray0
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .shadow(color: .pawBlack.opacity(0.1), radius: 6, x: 0, y: -4)
                .overlay(
                    RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                        .stroke(.gray30, lineWidth: 1)
                )
        )
    }

    var handle: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.gray30)
            .frame(width: 36, height: 4)
            .padding(.top, 12)
            .padding(.bottom, 4)
    }

    var noticeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(.iconNotion)
                Text("안내 사항")
                    .typography(.body1M)
                    .foregroundStyle(.gray90)
            }
            VStack(alignment: .leading, spacing: 6) {
                NoticeItem(text: "본 검사는 의학적 진단을 대체하지 않습니다.")
                NoticeItem(text: "정확한 진단을 위해서는 전문가와의 상담이 필요합니다.")
                NoticeItem(text: "해당 검사 결과는 7일간 리포트 감정 요약에 반영됩니다.")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.rowMuted)
        .cornerRadius(20, corners: .allCorners)
    }

    var sourceSection: some View {
        HStack {
            Text("출처")
                .typography(.body1M)
                .foregroundStyle(.gray80)
            Spacer()
            Text(store.assessmentType.source)
                .typography(.body4R)
                .foregroundStyle(.gray50)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.gray20)
        .cornerRadius(20, corners: .allCorners)
    }
}

// MARK: - Preview

#Preview("기록 없음") {
    NavigationStack {
        SelfAssessmentResultView(
            store: Store(
                initialState: SelfAssessmentResultState(
                    assessmentType: .pbq,
                    score: 30,
                    historyState: .noRecord
                )
            ) {
                SelfAssessmentResultFeature()
            }
        )
    }
}

#Preview("변화 없음") {
    NavigationStack {
        SelfAssessmentResultView(
            store: Store(
                initialState: SelfAssessmentResultState(
                    assessmentType: .pbq,
                    score: 30,
                    historyState: .noChange(
                        previousScore: 30,
                        previousDate: "2000.00.00",
                        currentScore: 30,
                        currentDate: "2000.00.00"
                    )
                )
            ) {
                SelfAssessmentResultFeature()
            }
        )
    }
}

#Preview("악화") {
    NavigationStack {
        SelfAssessmentResultView(
            store: Store(
                initialState: SelfAssessmentResultState(
                    assessmentType: .pbq,
                    score: 40,
                    historyState: .worsened(
                        previousScore: 20,
                        previousDate: "2000.00.00",
                        currentScore: 40,
                        currentDate: "2000.00.00",
                        difference: 20
                    )
                )
            ) {
                SelfAssessmentResultFeature()
            }
        )
    }
}

#Preview("완화") {
    NavigationStack {
        SelfAssessmentResultView(
            store: Store(
                initialState: SelfAssessmentResultState(
                    assessmentType: .pds,
                    score: 40,
                    historyState: .improved(
                        previousScore: 60,
                        previousDate: "2000.00.00",
                        currentScore: 40,
                        currentDate: "2000.00.00",
                        difference: 20
                    )
                )
            ) {
                SelfAssessmentResultFeature()
            }
        )
    }
}
