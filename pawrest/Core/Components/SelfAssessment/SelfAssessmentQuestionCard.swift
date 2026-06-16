//
//  SelfAssessmentQuestionCard.swift
//  pawrest
//
//  Created by Moon AYoung on 6/15/26.
//

import SwiftUI

struct SelfAssessmentQuestionCard: View {
    let question: SelfAssessmentQuestion
    let category: String?
    let options: [SelfAssessmentOption]
    let selectedIndex: Int?
    let onOptionSelected: (Int) -> Void
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            numberSection
            textSection
            divider
            optionsSection
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(20, corners: .allCorners)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.gray10, lineWidth: 1)
        )
    }
}

// MARK: - Subviews

private extension SelfAssessmentQuestionCard {
    
    var numberSection: some View {
        Text("\(question.id).")
            .typography(.title1)
            .foregroundColor(.pawPrimary)
    }
    
    @ViewBuilder
    var textSection: some View {
        if let category {
            Text(category)
                .typography(.body3M)
                .foregroundColor(.pawPrimary)
                .padding(.top, 18)
            
            Text(question.text)
                .typography(.body1R)
                .foregroundColor(.gray80)
                .padding(.top, 4)
        } else {
            Text(question.text)
                .typography(.body1R)
                .foregroundColor(.gray80)
                .padding(.top, 18)
        }
    }
    
    var divider: some View {
        CommunityDivider()
            .padding(.top, 18)
    }
    
    var optionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                HStack {
                    Text(option.text)
                        .typography(.body2R1)
                        .foregroundColor(.gray70)
                    
                    Spacer()
                    
                    SelfAssessmentRadioButton(
                        isSelected: selectedIndex == index,
                        action: { onOptionSelected(index) }
                    )
                }
            }
        }
        .padding(.top, 18)
    }
}
