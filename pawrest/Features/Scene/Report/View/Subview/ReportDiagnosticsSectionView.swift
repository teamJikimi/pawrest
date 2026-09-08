//
//  ReportDiagnosticsSectionView.swift
//  pawrest
//
//  Created by 소은 on 9/3/26.
//

import SwiftUI

struct ReportDiagnosticsSectionView: View {
    let assessmentRecords: [AssessmentRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            if assessmentRecords.isEmpty {
                emptyState
            } else {
                recordsList
            }
        }
        .padding(.vertical, 16)
        .background(.gray10)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("자가진단 검사 기록")
                .typography(.body1M)
                .foregroundStyle(.gray80)
            Text("의학적 진단이 아닌 참고 지표에요")
                .typography(.caption)
                .foregroundStyle(.gray60)
                .padding(.bottom, 6)
        }
        .padding(.leading, 36)
        .padding(.bottom, 12)
    }

    private var emptyState: some View {
        Text("아직 검사 기록이 없어요")
            .typography(.body3R)
            .foregroundStyle(.gray40)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 24)
    }

    private var recordsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(assessmentRecords) { record in
                    if let type = record.type {
                        let previous = assessmentRecords
                            .filter { $0.typeRawValue == record.typeRawValue && $0.date < record.date }
                            .first
                        StatusCard(
                            title: type.title,
                            date: record.date,
                            score: record.totalScore,
                            maxScore: type.toScaleType.maxScore,
                            previousScore: previous?.totalScore,
                            previousDate: previous?.date,
                            scaleType: type.toScaleType
                        )
                        .frame(width: 260, height: 175)
                        .clipped()
                    }
                }
            }
            .padding(.leading, 36)
            .padding(.bottom, 20)
        }
        .frame(height: 164)
        .scrollContentBackground(.hidden)
    }
}
