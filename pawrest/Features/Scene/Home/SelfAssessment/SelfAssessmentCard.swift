//
//  SelfAssessmentCard.swift
//  pawrest
//
//  Created by 소은 on 6/18/26.
//

import SwiftUI

struct SelfAssessmentCard: View {
    let onTap: (SelfAssessmentType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerLabel
            
            VStack(spacing: 6) {
                ForEach(SelfAssessmentType.allCases) { type in
                    assessmentRow(type)
                }
            }
        }
        .padding()
        .background(.gray10)
        .cornerRadius(20, corners: .allCorners)
    }
}

// MARK: - Subviews

private extension SelfAssessmentCard {
    
    var headerLabel: some View {
        HStack(spacing: 4) {
            Image(.imageSelfAssessment)
                .resizable()
                .frame(width: 14, height: 14)
            
            Text("심리 검사")
                .typography(.body1M)
                .foregroundStyle(.gray90)
        }
        .padding(.bottom, 12)
    }
    
    
    func assessmentRow(_ type: SelfAssessmentType) -> some View {
        Button {
            onTap(type)
        } label: {
            HStack {
                Text(type.title)
                    .typography(.body2R1)
                    .foregroundStyle(.gray80)
                
                Spacer()
            }
            .padding(.leading, 12)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(.gray0)
            .cornerRadius(10, corners: .allCorners)
        }
        .buttonStyle(.plain)
    }
}
