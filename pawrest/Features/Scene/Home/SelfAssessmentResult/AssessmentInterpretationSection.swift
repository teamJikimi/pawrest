//
//  AssessmentInterpretationSection.swift
//  pawrest
//
//  Created by 소은 on 6/14/26.
//

import SwiftUI

struct AssessmentInterpretationSection: View {
    let rows: [AssessmentInterpretationRow]
    let currentLevel: AssessmentScoreLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("점수 해석 기준")
                .typography(.body1Accent)
                .foregroundStyle(.gray90)
                .padding(.bottom, 12)

            VStack(spacing: 6) {
                ForEach(rows, id: \.level.label) { row in
                    InterpretationRow(
                        row: row,
                        isHighlighted: row.level == currentLevel
                    )
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray10)
        .cornerRadius(20, corners: .allCorners)
    }
}

// MARK: - InterpretationRow

private struct InterpretationRow: View {
    let row: AssessmentInterpretationRow
    let isHighlighted: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray0)
                    .frame(width: 32, height: 32)
                
                Image(row.level.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
            
            Text(row.level.label)
                .typography(.body2Accent)
                .foregroundStyle(row.level.scoreColor)

            Spacer()

            Text(row.level.rangeText)
                .typography(.body3R)
                .foregroundStyle(.gray80)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(row.level.badgeBackground)
                .cornerRadius(6, corners: .allCorners)
        }
        .padding(8)
        .background(row.level.scoreColor.opacity(0.1))
        .cornerRadius(12, corners: .allCorners)
    }
}


#Preview {
    AssessmentInterpretationSection(
        rows: [
            AssessmentInterpretationRow(level: .cesDNormal),
            AssessmentInterpretationRow(level: .cesDHighRisk),
            AssessmentInterpretationRow(level: .cesDDepression)
        ],
        currentLevel: .cesDHighRisk
    )
    .padding(20)
}
