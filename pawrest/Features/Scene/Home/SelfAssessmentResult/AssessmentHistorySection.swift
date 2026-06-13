//
//  AssessmentHistorySection.swift
//  pawrest
//
//  Created by 소은 on 6/14/26.
//

import SwiftUI

// MARK: - View

struct AssessmentHistorySection: View {
    let historyState: AssessmentHistoryState

    var body: some View {
        switch historyState {
        case .noRecord:
            noRecordView
        case let .noChange(previousScore, previousDate, currentScore, currentDate):
            historyView(
                previousScore: previousScore,
                previousDate: previousDate,
                currentScore: currentScore,
                currentDate: currentDate,
                changeView: AnyView(noChangeView)
            )
        case let .worsened(previousScore, previousDate, currentScore, currentDate, difference):
            historyView(
                previousScore: previousScore,
                previousDate: previousDate,
                currentScore: currentScore,
                currentDate: currentDate,
                changeView: AnyView(worsenedView(difference: difference))
            )
        case let .improved(previousScore, previousDate, currentScore, currentDate, difference):
            historyView(
                previousScore: previousScore,
                previousDate: previousDate,
                currentScore: currentScore,
                currentDate: currentDate,
                changeView: AnyView(improvedView(difference: difference))
            )
        }
    }
}

// MARK: - Subviews

private extension AssessmentHistorySection {

    var noRecordView: some View {
        VStack(spacing: 8) {
            Image(.imageAssessmentEmpty)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 32)
                .foregroundStyle(.gray40)

            Text("이전 기록 없음")
                .typography(.title2)
                .foregroundStyle(.gray70)

            Text("다음 검사부터 변화를 함께 보여드려요.")
                .typography(.body2R1)
                .foregroundStyle(.gray50)
        }
        .frame(maxWidth: .infinity, maxHeight: 158)
        .padding(.vertical, 24)
        .background(.gray10)
        .cornerRadius(20, corners: .allCorners)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 0)
    }

    func historyView(
        previousScore: Int,
        previousDate: String,
        currentScore: Int,
        currentDate: String,
        changeView: AnyView
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이전 검사 기록")
                .typography(.title2)
                .foregroundStyle(.gray90)

            HStack(spacing: 0) {
                ScoreHistoryCard(
                    label: "이전 검사",
                    score: previousScore,
                    date: previousDate,
                    isHighlighted: false
                )

                Spacer()

                changeView

                Spacer()

                ScoreHistoryCard(
                    label: "현재 검사",
                    score: currentScore,
                    date: currentDate,
                    isHighlighted: true
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.gray10)
        .cornerRadius(20, corners: .allCorners)
    }

    var noChangeView: some View {
        VStack(spacing: 4) {
            Image(.iconScoreNeutral)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            Text("변화 없음")
                .typography(.body2R1)
                .foregroundStyle(Color.gray50)
        }
    }

    func worsenedView(difference: Int) -> some View {
        VStack(spacing: 4) {
            Image(.iconScoreUp)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            Text("\(difference)점 증가")
                .typography(.body2R1)
                .foregroundStyle(Color(.danger))
        }
    }

    func improvedView(difference: Int) -> some View {
        VStack(spacing: 4) {
            Image(.iconScoreDown)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            Text("\(difference)점 감소")
                .typography(.body2R1)
                .foregroundStyle(.pawPrimary)
        }
    }
}

// MARK: - ScoreHistoryCard

private struct ScoreHistoryCard: View {
    let label: String
    let score: Int
    let date: String
    let isHighlighted: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .typography(.body2R1)
                .foregroundStyle(.gray60)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(isHighlighted ? .primaryLight : .gray40)
                .cornerRadius(10, corners: .allCorners)

            Text("\(score)")
                .typography(.pageTitle)
                .foregroundStyle(isHighlighted ? .gray80 : .gray60)

            Text(date)
                .typography(.date)
                .foregroundStyle(.gray60)
        }
        .frame(width: 115)
        .padding(.vertical, 12)
        .background(isHighlighted ? .gray0 : .gray20)
        .cornerRadius(10, corners: .allCorners)
    }
}
