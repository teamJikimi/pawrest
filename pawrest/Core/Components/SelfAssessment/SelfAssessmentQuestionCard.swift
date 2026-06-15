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
            //
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
